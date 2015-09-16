This repo is cenetered around a Docker container for a ROS 
workspace designed to control the barrett hand and staubli
robotic arm. It is currently a work in progess.

Dependencies:
-------------
[Docker](https://docs.docker.com/installation/ubuntulinux/)

[ROS](http://wiki.ros.org/hydro/Installation/Ubuntu) (if you
want to interact with the server from the host machine)

Currently implemented:
======================
- [X] Barrett hand ([see here](http://wiki.ros.org/barrett_hand))
- [ ] Staubli arm
- [ ] Planner
- [ ] Launch file / controller for both parts of the robot

Building the container image:
=============================
`docker build -t curg-robot-server .`

Running the robot:
==================
`docker run -d --privileged -p 11311:11311 curg-robot-server`
This will spin up a *robot-server* in the background, launching 
rosmaster on port 11311. 

To run the container in interactive mode in a bash shell you can
run the following command:
`docker run --privileged -p 11311:11311 -ti curg-robot-server bash`
