#!/bin/bash
set -e
FIRMWAREURL="https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/"

ROOT="$(pwd)"
BUILD_DIR="${ROOT}/build"
BUILD_TMP=$(mktemp -d)
mkdir -p $BUILD_DIR

SRC_DIR="$(pwd)/$1"
[ ! -e "$SRC_DIR" ] && { echo "The file/directory specified doesn't exist: ${SRC_DIR}"; exit 1; }
[ -z "$2" ] && APP="tamago-kernel" || APP="$2"

for firmware in LICENCE.broadcom bootcode.bin fixup.dat start.elf; do
  firmware_dest="${BUILD_DIR}/${firmware}"
  if [ ! -f "${firmware_dest}" ]; then
    echo "Downloading RPi firmware: ${firmware}"
    curl --silent --output "${firmware_dest}" "${FIRMWAREURL}${firmware}";
  fi
done

export GO_EXTLINK_ENABLED=0
export CGO_ENABLED=0
export GOOS=tamago
export GOARM=5
export GOARCH=arm

TEXT_START=0x00010000 # Space for interrupt vector, etc

/usr/local/tamago-go/bin/go build -ldflags "-s -w -T ${TEXT_START} -E _rt0_arm_tamago -R 0x1000" -o "${BUILD_TMP}/${APP}" "$SRC_DIR"
objdump -D "${BUILD_TMP}/${APP}" > "${BUILD_TMP}/${APP}.list"

objcopy -j .text -j .rodata -j .shstrtab -j .typelink \
  -j .itablink -j .gopclntab -j .go.buildinfo -j .noptrdata -j .data \
  -j .bss --set-section-flags .bss=alloc,load,contents \
  -j .noptrbss --set-section-flags .noptrbss=alloc,load,contents \
  "${BUILD_TMP}/${APP}" -O binary "${BUILD_TMP}/${APP}.o"

ENTRY_POINT=$(readelf -e "${BUILD_TMP}/${APP}" | grep Entry | sed 's/.*\(0x[a-zA-Z0-9]*\).*/\1/')
gcc -D ENTRY_POINT="${ENTRY_POINT}" -c /tamago-build/boot.S -o "${BUILD_TMP}/boot.o"

objcopy "${BUILD_TMP}/boot.o" -O binary "${BUILD_TMP}/stub.o"

# Truncate pads the stub out to correctly align the binary
# 32768 = 0x10000 (TEXT_START) - 0x8000 (Default kernel load address)
truncate -s 32768 "${BUILD_TMP}/stub.o"

cat "${BUILD_TMP}/stub.o" "${BUILD_TMP}/${APP}.o" > "${BUILD_DIR}/${APP}.bin"

cp "/tamago-build/config.txt" "${BUILD_DIR}/config.txt"

rm -rf "${BUILD_TMP}"

