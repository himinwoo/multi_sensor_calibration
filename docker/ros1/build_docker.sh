#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

docker build \
    -t multi_sensor_calibration:melodic \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${ROOT_DIR}"
