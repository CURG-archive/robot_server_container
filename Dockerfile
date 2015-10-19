FROM ubuntu:12.04
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# DEBUGGING!
#RUN apt-get update && apt-get install python-pip -y && pip install ipython

# ===== Dependencies =====
RUN apt-get update
RUN apt-get install ca-certificates -y
RUN apt-get install wget -y
RUN apt-get install curl -y
RUN apt-get install libpopt-dev -y
RUN apt-get install libstdc++6-4.6-dev -y
RUN apt-get install make -y
RUN apt-get install linux-headers-$(uname -r) -y
RUN apt-get install swig -y

RUN echo "deb http://packages.ros.org/ros/ubuntu precise main" > /etc/apt/sources.list.d/ros-latest.list
RUN wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | apt-key add -
RUN apt-get update
#RUN apt-get install -y ros-hydro-desktop-full
RUN apt-get install ros-hydro-ros-base -y
RUN apt-get install ros-hydro-sensor-msgs -y

# ===== Initialize ROS =====
RUN rosdep init
RUN rosdep update
RUN source /opt/ros/hydro/setup.bash
RUN apt-get update
RUN apt-get install python-rosinstall -y

# ===== PCAN driver =====
RUN mkdir -p /opt/curg/temp/pcan
# We use a slightly modified version of the peak-linux-driver found below
#http://www.peak-system.com/fileadmin/media/linux/files/peak-linux-driver-7.10.tar.gz
ADD ./docker-peak-driver/peak-linux-driver-7.10 /opt/curg/temp/peak-linux-driver-7.10
WORKDIR /opt/curg/temp/peak-linux-driver-7.10
RUN make NET=NO_NETDEV_SUPPORT
RUN make install
RUN modprobe pcan

# ===== PCAN library (pcan_python)
RUN curl https://codeload.github.com/RobotnikAutomation/pcan_python/tar.gz/master | tar xvz -C /opt/curg/temp
WORKDIR /opt/curg/temp/pcan_python-master
RUN make
RUN make install
RUN echo "export PYTHONPATH=$PYTHONPATH:/usr/lib" >> /root/.bashrc.curg

# ===== CURG folder =====
# all CURG-related files should go here...
RUN mkdir -p /opt/curg/robot_server

# ===== Create workspace =====
RUN mkdir -p /opt/curg/robot_server/src
WORKDIR /opt/curg/robot_server/src
# docker does weird things w/ executables linked to w/ the source command
# combining `source` and whatever command you're using simplifies things...
RUN source /opt/ros/hydro/setup.bash && catkin_init_workspace

# ===== Barrett hand =====
RUN curl https://codeload.github.com/RobotnikAutomation/barrett_hand/tar.gz/hydro-devel | tar xvz -C /opt/curg/temp/
RUN mv /opt/curg/temp/barrett_hand-hydro-devel/barrett_hand /opt/curg/robot_server/src/
RUN mv /opt/curg/temp/barrett_hand-hydro-devel/bhand_controller /opt/curg/robot_server/src/
RUN mv /opt/curg/temp/barrett_hand-hydro-devel/bhand_description /opt/curg/robot_server/src/

# ===== Cleanup! =====
RUN rm -rf /opt/curg/temp/*

# ===== BUILD! =====
WORKDIR /opt/curg/robot_server
RUN source /opt/ros/hydro/setup.bash && catkin_make

# Run the barretthand server...
EXPOSE 11311
RUN echo "source /opt/curg/robot_server/devel/setup.bash" >> /root/.bashrc.curg
RUN echo "source /root/.bashrc.curg" >> /root/.bashrc
ENTRYPOINT export ROS_MASTER_URI=http://$(/sbin/ip route|awk '/default/ { print $3 }'):11311/ && source /root/.bashrc.curg && roslaunch bhand_controller bhand_controller.launch
