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
`docker run -d --net host --privileged curg-robot-server`
This will spin up a *robot-server* in the background. The server will automatically connect to a rosmaster running on docker's host machine (port 11311). 
Note: the `--net host` option forces the container to use the host's network adapter (and namespace) rather than spinning up it's own. If you know how to get the container's indiviual IP address and are comfortable doing some advanced networking with ROS you can just use the container's IP and ports for each topic/service to free up space in your local namespace. 

To run the container in interactive mode in a bash shell you can
run the following command:
`docker run --privileged -ti curg-robot-server bash`

