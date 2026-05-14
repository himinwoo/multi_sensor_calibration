#!/usr/bin/env bash
set -euo pipefail

# Build script for multi_sensor_calibration workspace inside Docker.
# Run this inside the container after starting it with run_docker.sh.

WS_DIR="/workspace/calib_ws"
ROS_DISTRO="${ROS_DISTRO:-melodic}"

echo "========================================"
echo "Building multi_sensor_calibration workspace"
echo "ROS distro: ${ROS_DISTRO}"
echo "Python: $(python3 --version)"
echo "========================================"

source "/opt/ros/${ROS_DISTRO}/setup.bash"

cd "${WS_DIR}"

# Install any missing ROS dependencies via rosdep
echo "--> Running rosdep install..."
rosdep install --from-paths src --ignore-src -r -y --rosdistro "${ROS_DISTRO}"

# Clean previous build artifacts to avoid CMake cache issues when switching Python versions
if [ -d build ] || [ -d devel ]; then
    echo "--> Cleaning previous build artifacts..."
    rm -rf build devel
fi

# Build workspace with Python 3
echo "--> Running catkin_make with Python 3..."
ROS_PYTHON_VERSION=3 catkin_make \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
    -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so

echo ""
echo "========================================"
echo "Build completed successfully!"
echo "Source the workspace before running nodes:"
echo "  source ${WS_DIR}/devel/setup.bash"
echo "========================================"
