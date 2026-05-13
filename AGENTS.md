# AGENTS.md — multi_sensor_calibration

ROS-based extrinsic calibration toolbox for lidar, camera, and radar sensors (ICRA 2019).

## Repository Structure

- **Catkin workspace package** with 9 ROS packages:
  - `accumulator` — collects calibration board detections from all sensors
  - `optimization` — Python optimizer (can run standalone or as ROS node)
  - `lidar_detector`, `stereo_detector`, `mono_detector`, `radar_detector` — sensor-specific detectors
  - `urdf_calibration` — updates URDF with calibrated poses
  - `common` — shared C++ library (robust least squares)
  - `multi_sensor_calibration_launch` — launch files and scripts

## Build

This repo **must** live inside a catkin workspace `src/` folder:

```bash
git clone https://github.com/tudelft-iv/multi_sensor_calibration.git <catkin_ws>/src/
cd <catkin_ws>
catkin_make
source devel/setup.bash
```

- C++11 is required (`add_compile_options(-std=c++11)` in some packages).
- CMake minimum version is 2.8.3 across packages.
- Include directories in `CMakeLists.txt` use `include_directories(include/${PROJECT_NAME})`.

## Dependencies

### ROS packages
```bash
apt-get install ros-<ros_distro>-desktop-full
apt-get install ros-<ros_distro>-pcl-ros
apt-get install ros-<ros_distro>-opencv3
apt-get install ros-<ros_distro>-cv-bridge
apt-get install ros-<ros_distro>-ros-numpy
apt-get install ros-<ros_distro>-astuff-sensor-msgs
```

### System
```bash
apt-get install libeigen3-dev build-essential cmake python3-dev \
  python3-setuptools libatlas-dev libatlas3-base libpcl-dev libyaml-cpp-dev
```

### Python (pip3)
```bash
pip3 install numpy scipy matplotlib pyyaml scikit-learn rmsd rospkg tikzplotlib
```

### Key C++ libraries
- PCL (used heavily in `lidar_detector`)
- yaml-cpp (used in `accumulator`, `lidar_detector`, `urdf_calibration`, `mono_detector`)

## Running Components

### Full pipeline via launch files
```bash
roslaunch multi_sensor_calibration_launch detectors.launch
roslaunch multi_sensor_calibration_launch accumulator.launch
roslaunch multi_sensor_calibration_launch optimizer.launch
```

### Standalone optimizer (no ROS needed for basic use)
```bash
cd optimization/
python3 src/main.py --lidar data/example_data/lidar.csv \
  --camera data/example_data/camera.csv --radar data/example_data/radar.csv \
  --calibration-mode 3 --visualise
```

Calibration modes: see `optimization/src/optimization/optimize.py` function `joint_optimization`.

### Manual ROS nodes
```bash
rosrun lidar_detector lidar_detector_node
rosrun radar_detector radar_detector_node
rosrun stereo_detector stereo_detector_node
rosrun mono_detector mono_detector_node
rosrun accumulator accumulator
rosrun optimization server.py
```

## Configuration

- **Detector configs** (YAML): `lidar_detector/config/config.yaml`, `stereo_detector/config/config.yaml`, `mono_detector/config/config.yaml`
- **Radar detector** config is passed as ROS parameters (see `multi_sensor_calibration_launch/launch/detectors.launch`)
- **Sensor setup / calibration board geometry**: edit `optimization/src/optimization/config.py` and `optimization/src/optimization/calibration_board.py`
- **Calibration mode / reference sensor** can be changed via rosparam:
  ```bash
  rosparam set /optimizer/calibration_mode <mode>
  rosparam set /optimizer/reference_sensor <sensor_name>
  ```

## Service Calls (Accumulator)

```bash
rosservice call /accumulator/toggle_accumulate   # start/stop recording
rosservice call /accumulator/optimize            # run calibration
rosservice call /accumulator/save "data: {data: '<path>.yaml'}"
rosservice call /accumulator/load "data: {data: '<path>.yaml'}"
```

## Outputs

- Results are written to `results/` directory by default:
  - YAML files with transformation matrices (source → target)
  - Launch files with `static_transform_publisher` for each sensor

## URDF Update

```bash
rosrun urdf_calibration urdf_calibration <input_urdf> <calibration_yaml> <output_urdf> <link_to_update> <joint_to_update>
```

Repeat for every sensor. Do **not** update the same link/joint twice (incorrect result if sensors share a common parent). Example script: `multi_sensor_calibration_launch/scripts/update_prius_urdf.sh`.

## Testing

- No formal test suite is configured. `catkin_make run_tests` is not wired up.
- `mono_detector/test/yaml.cpp` and `urdf_calibration/test/` contain some manual test assets, but they are not integrated into the build.
- To verify changes, run the standalone optimizer examples in `optimization/data/example_data/`.

## Important Conventions

- **Python package setup**: `optimization` uses `catkin_pkg.python_setup.generate_distutils_setup` in `setup.py`; do not modify package paths without updating `CMakeLists.txt` and `setup.py` together.
- **Correspondence methods**: Two methods exist for lidar-camera point correspondences. The recommended one reorders detections based on a reference sensor using centroid-based initial pose. See README section "How are the (point) correspondences determined".
- **Partial FOV calibration**: Supported but experimental. Requires `mode = 'remove_detections'` in `config.py` (or `outlier_removal` rosparam for ROS node) and one sensor seeing all board locations as reference.
- **Multiple sensors of same modality**: Supported. Launch multiple detector instances with remapped topics.

## Files That Explain the System

- `README.md` — full tutorial and FAQ
- `docs/detectors.md` — detector topics and parameters
- `docs/calibration_board.md` — calibration board specifications
- `optimization/src/optimization/optimize.py` — calibration modes explained in code comments
