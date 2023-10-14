FROM osrf/ros:noetic-desktop-full-focal

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO noetic

# install depends
RUN apt update && \
    apt install -y python3-catkin-tools ros-noetic-geographic-msgs ros-noetic-tf2-sensor-msgs ros-noetic-tf2-geometry-msgs ros-noetic-image-transport && \
    apt install -y git wget vim net-tools && \
    apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool && \
    apt install -y ninja-build build-essential cmake tree pkg-config curl dkms rename g++ gcc unzip && \
    apt install -y libeigen3-dev libsuitesparse-dev libboost-all-dev libgoogle-glog-dev libgflags-dev libgtest-dev && \
    apt install -y ffmpeg libpcl-dev libglew-dev libatlas-base-dev libatlas-base-dev && \
    apt install -y libgtk2.0-dev libtbb-dev libswscale-dev libavdevice-dev libjpeg-dev libpng-dev libtiff5-dev libopenexr-dev && \
    apt install -y ros-$ROS_DISTRO-hector-trajectory-server && \
    rm -rf /var/lib/apt/lists/*

# set user and group
ARG USERNAME=m
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

# zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell  \ 
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting
RUN sudo echo "source /opt/ros/noetic/setup.zsh" >> /home/$USERNAME/.zshrc

# llvm clang
RUN wget -P /home/$USERNAME/pkg/llvm https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.4/clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    tar -xf /home/$USERNAME/pkg/llvm/clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    sudo cp -r /home/$USERNAME/pkg/llvm/clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04/* /usr && \
    rm -rf /home/$USERNAME/pkg/llvm

# Ceres
WORKDIR /home/$USERNAME/pkg/ceres
RUN wget https://github.com/ceres-solver/ceres-solver/archive/refs/tags/2.2.0rc3.tar.gz && \
    tar -xf 2.2.0rc3.tar.gz && cd ceres-solver-2.2.0rc3 && mkdir build && cd build && \
    cmake -G Ninja .. && ninja && sudo ninja install && ninja clean && \
    rm /home/$USERNAME/pkg/ceres/2.2.0rc3.tar.gz

# g2o
WORKDIR /home/$USERNAME/pkg
RUN git clone --depth 1 https://github.com/RainerKuemmerle/g2o.git g2o && cd g2o && \
    mkdir build && cd build && \
    cmake -G Ninja .. && ninja && sudo ninja install && ninja clean

# OpenCV
WORKDIR /home/$USERNAME/pkg/OpenCV
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.x.zip && \
    unzip opencv.zip && unzip opencv_contrib.zip && \
    mkdir -p build && cd build && \
    cmake -GNinja -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-4.x/modules ../opencv-4.x && \
    ninja && sudo ninja install && ninja clean && \
    rm /home/$USERNAME/pkg/OpenCV/opencv.zip && rm /home/$USERNAME/pkg/OpenCV/opencv_contrib.zip

WORKDIR /home/$USERNAME/

ENTRYPOINT [ "/bin/zsh" ]