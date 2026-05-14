#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

DATA_DIR="${DATA_DIR:-${ROOT_DIR}/data}"
RESULTS_DIR="${RESULTS_DIR:-${ROOT_DIR}/optimization/results}"

mkdir -p "${DATA_DIR}" "${RESULTS_DIR}"

# Optional: allow privileged mode for hardware sensor access (USB cameras, etc.)
PRIVILEGED_FLAG=""
if [[ "${PRIVILEGED:-0}" == "1" ]]; then
    PRIVILEGED_FLAG="--privileged"
fi

# X11 authorization: prefer xhost SI (secure) if available, otherwise warn
if command -v xhost >/dev/null 2>&1; then
    if xhost +SI:localuser:"$(id -un)" >/dev/null 2>&1; then
        :
    else
        echo "Warning: Could not set xhost with SI:localuser. Falling back to +local:docker (less secure)."
        xhost +local:docker >/dev/null 2>&1 || true
    fi
else
    echo "Warning: xhost not found. GUI applications may not work."
fi

docker run -it --rm \
    --name multi_sensor_calibration_melodic \
    --net=host \
    --ipc=host \
    ${PRIVILEGED_FLAG} \
    --shm-size=8g \
    --cpus="$(nproc)" \
    -e DISPLAY="${DISPLAY}" \
    -e QT_X11_NO_MITSHM=1 \
    -e ROS_MASTER_URI="${ROS_MASTER_URI:-http://localhost:11311}" \
    -e ROS_PYTHON_VERSION=3 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "${ROOT_DIR}:/workspace/calib_ws/src/multi_sensor_calibration:rw" \
    -v "${DATA_DIR}:/workspace/calib_ws/data:rw" \
    -v "${RESULTS_DIR}:/workspace/calib_ws/src/multi_sensor_calibration/optimization/results:rw" \
    ${EXTRA_DOCKER_ARGS:-} \
    -w /workspace/calib_ws \
    multi_sensor_calibration:melodic \
    bash
