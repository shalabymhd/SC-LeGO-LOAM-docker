# Use ROS Melodic base image
FROM osrf/ros:melodic-desktop-full

# Install required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \ 
    unzip \
    libmetis-dev \
    ros-melodic-pcl-ros \
    ros-melodic-tf \
    ros-melodic-geometry-msgs \
    ros-melodic-nav-msgs \
    ros-melodic-sensor-msgs \
    ros-melodic-visualization-msgs \
    ros-melodic-cv-bridge \
    libpcl-dev \
    libeigen3-dev \
    libboost-all-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# pip install dependencies and additional useful packages 
RUN pip3 install --upgrade pip

RUN pip3 install \
    numpy \ 
    pandas \
    cython \ 
    pyyaml \ 
    rospkg \ 
    pycryptodomex \ 
    matplotlib \ 
    scipy \ 
    gnupg \
    PyQt5 \
    open3d

# Install GTSAM
WORKDIR /
RUN wget -O ./gtsam.zip https://github.com/borglab/gtsam/archive/4.0.0-alpha2.zip
RUN unzip gtsam.zip -d ./
WORKDIR /gtsam-4.0.0-alpha2/
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Set up the catkin workspace
RUN mkdir -p /root/catkin_ws/src
WORKDIR /root/catkin_ws/src

# Clone LEGO-LOAM repository
RUN git clone https://github.com/shalabymhd/SC-LeGO-LOAM-docker.git

# Build the workspace
WORKDIR /root/catkin_ws
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && catkin_make"

# Source the workspace in every new shell
RUN echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc

# Default command: source the workspace and launch
CMD ["/bin/bash", "-c", "source /root/catkin_ws/devel/setup.bash && bash"]

# Optionally expose ROS master port (11311)
EXPOSE 11311