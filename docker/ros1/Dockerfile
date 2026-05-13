FROM osrf/ros:melodic-desktop-full-bionic

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=melodic \
    CATKIN_WS=/workspace/calib_ws

# ------------------------------------------------------------------------------
# System + ROS dependencies
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    vim \
    nano \
    bash-completion \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-numpy \
    python3-scipy \
    python3-matplotlib \
    python3-yaml \
    python3-sklearn \
    python3-tk \
    python-rospkg \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
    libeigen3-dev \
    libatlas-base-dev \
    libatlas3-base \
    libpcl-dev \
    libyaml-cpp-dev \
    ros-melodic-pcl-ros \
    ros-melodic-cv-bridge \
    ros-melodic-ros-numpy \
    ros-melodic-astuff-sensor-msgs \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Python pip dependencies
# ------------------------------------------------------------------------------
RUN pip3 install --no-cache-dir \
    numpy \
    scipy \
    matplotlib \
    pyyaml \
    scikit-learn \
    rmsd \
    rospkg \
    "tikzplotlib<0.9.9"

# ------------------------------------------------------------------------------
# Catkin workspace skeleton
# ------------------------------------------------------------------------------
RUN mkdir -p ${CATKIN_WS}/src ${CATKIN_WS}/data ${CATKIN_WS}/results

# ------------------------------------------------------------------------------
# rosdep
# ------------------------------------------------------------------------------
RUN rosdep init || true && rosdep update || true

# ------------------------------------------------------------------------------
# Shell environment
# ------------------------------------------------------------------------------
SHELL ["/bin/bash", "-c"]

RUN printf '%s\n' \
    'source /opt/ros/melodic/setup.bash' \
    'if [ -f /workspace/calib_ws/devel/setup.bash ]; then source /workspace/calib_ws/devel/setup.bash; fi' \
    'alias cb="cd /workspace/calib_ws && catkin_make"' \
    'alias cs="cd /workspace/calib_ws/src/multi_sensor_calibration"' \
    'alias cw="cd /workspace/calib_ws"' \
    >> /root/.bashrc

WORKDIR /workspace/calib_ws

CMD ["/bin/bash"]
