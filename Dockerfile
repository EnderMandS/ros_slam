FROM endermands/ros_noetic_zsh:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO noetic
ARG USERNAME=m

# install depends
RUN sudo apt update && \
    sudo apt install -y python3-catkin-tools ros-$ROS_DISTRO-geographic-msgs ros-$ROS_DISTRO-tf2-sensor-msgs ros-$ROS_DISTRO-tf2-geometry-msgs ros-$ROS_DISTRO-image-transport && \
    sudo apt install -y git wget vim net-tools && \
    sudo apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool && \
    sudo apt install -y ninja-build build-essential cmake tree curl dkms rename unzip && \
    sudo apt install -y libeigen3-dev libsuitesparse-dev libboost-all-dev libgoogle-glog-dev libgflags-dev libgtest-dev && \
    sudo apt install -y ffmpeg libpcl-dev libglew-dev libatlas-base-dev libatlas-base-dev libmetis-dev libfmt-dev && \
    sudo apt install -y libgtk2.0-dev libtbb-dev libswscale-dev libavdevice-dev libjpeg-dev libpng-dev libomp-dev && \
    sudo apt install -y ros-$ROS_DISTRO-hector-trajectory-server && \
    sudo apt install -y libgl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols libegl1-mesa-dev && \
    sudo apt install -y libc++-dev libglew-dev libarmadillo-dev && \
    sudo rm -rf /var/lib/apt/lists/*

# # llvm clang
# WORKDIR /home/$USERNAME/pkg/llvm
# RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.4/clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
#     tar -xf clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
#     rm clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
#     cd clang+llvm-16.0.4-x86_64-linux-gnu-ubuntu-22.04 && \
#     sudo cp -r * /usr && \
#     rm -rf /home/$USERNAME/pkg/llvm

# Sophus
WORKDIR /home/$USERNAME/pkg
RUN git clone --depth 1 https://github.com/strasdat/Sophus.git Sophus && cd Sophus && \
    mkdir build && cd build && \
    cmake -G Ninja .. && ninja && sudo ninja install && ninja clean && \
    sudo ldconfig

# Ceres
WORKDIR /home/$USERNAME/pkg/ceres
RUN wget https://github.com/ceres-solver/ceres-solver/archive/refs/tags/2.2.0rc3.tar.gz && \
    tar -xf 2.2.0rc3.tar.gz && rm 2.2.0rc3.tar.gz && \
    cd ceres-solver-2.2.0rc3 && mkdir build && cd build && \
    cmake -G Ninja .. && ninja && sudo ninja install && ninja clean && \
    sudo ldconfig

# g2o
WORKDIR /home/$USERNAME/pkg
RUN git clone --depth 1 https://github.com/RainerKuemmerle/g2o.git g2o && cd g2o && \
    mkdir build && cd build && \
    cmake -G Ninja .. && ninja && sudo ninja install && ninja clean && \
    sudo ldconfig

# # OpenCV
# WORKDIR /home/$USERNAME/pkg/OpenCV
# RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip && \
#     wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.x.zip && \
#     unzip opencv.zip && rm opencv.zip && \
#     unzip opencv_contrib.zip && rm opencv_contrib.zip && \
#     mkdir build && cd build && \
#     cmake -GNinja -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-4.x/modules ../opencv-4.x && \
#     ninja && sudo ninja install && ninja clean && \
#     rm -rf /home/$USERNAME/pkg/OpenCV/opencv-4.x && rm -rf /home/$USERNAME/pkg/OpenCV/opencv_contrib-4.x

# Pangolin
WORKDIR /home/$USERNAME/pkg
RUN git clone --recursive --depth 1 https://github.com/stevenlovegrove/Pangolin.git && cd Pangolin && \
    mkdir build && cd build && \
    cmake -G Ninja .. && ninja && sudo ninja install && ninja clean && \
    sudo ldconfig

WORKDIR /home/$USERNAME/
RUN echo "soruce /opt/ros/${ROS_DISTRO}}/setup.zsh" >> /home/$USERNAME/.zshrc

ENTRYPOINT [ "/bin/zsh" ]