# coffee-dispenser-project

```
git clone --recursive https://github.com/Andy-Leo10/coffee-dispenser-project.git
```
```
git pull --recurse-submodules
```

- [coffee-dispenser-project](#coffee-dispenser-project)
- [SIMULATED ROBOT](#simulated-robot)
  - [0. For launching the simulation](#0-for-launching-the-simulation)
  - [1. For launching the move\_group and rviz nodes](#1-for-launching-the-move_group-and-rviz-nodes)
  - [2. For launching the vision system](#2-for-launching-the-vision-system)
  - [3. For launching the manipulation service server](#3-for-launching-the-manipulation-service-server)
  - [4. For launching the Foxglove's bridge](#4-for-launching-the-foxgloves-bridge)
  - [5. Others](#5-others)
- [REAL ROBOT](#real-robot)
  - [0. For checking the robot system](#0-for-checking-the-robot-system)
  - [1. For launching the move\_group and rviz nodes](#1-for-launching-the-move_group-and-rviz-nodes-1)
  - [2. For launching the vision system](#2-for-launching-the-vision-system-1)
  - [3. For launching the manipulation service server](#3-for-launching-the-manipulation-service-server-1)
  - [4. For launching the Foxglove's bridge](#4-for-launching-the-foxgloves-bridge-1)
  - [5. Others](#5-others-1)
- [DOCKER](#docker)
  - [Compose](#compose)
  - [Build](#build)
  - [Run](#run)
  - [New shell](#new-shell)
  - [Clean](#clean)
  - [Previous step for visualization](#previous-step-for-visualization)
  - [Previous step for Docker](#previous-step-for-docker)

---

<details>
<summary><b>SIMULATED ROBOT</b></summary>

# SIMULATED ROBOT
## 0. For launching the simulation
```
source ~/ros2_ws/install/setup.bash; ros2 launch the_construct_office_gazebo starbots_ur3e.launch.xml
```
```
cd ~/ros2_ws/ ;colcon build --packages-select barista_gazebo ur_description ur_simulation_gazebo the_construct_office_gazebo --event-handlers console_direct+; source install/setup.bash; ros2 launch the_construct_office_gazebo starbots_ur3e.launch.xml
```
Making sure things are working
```
ros2 topic echo /joint_states
ros2 topic echo /robot_description
ros2 topic echo /tf
ros2 control list_controllers
ros2 run tf2_ros tf2_echo base_link tool0
ros2 run tf2_tools view_frames
```

## 1. For launching the move_group and rviz nodes
```
cd ~/ros2_ws/; colcon build --packages-select sim_moveit_config; source ~/ros2_ws/install/setup.bash; ros2 launch sim_moveit_config run_moveit.xml
```

## 2. For launching the vision system
Set the environment
```
export PYTHONPATH=$PYTHONPATH:/home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_perception/venv/lib/python3.10/site-packages/
```
```
cd /home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_perception; source venv/bin/activate
```
**LAUNCH**
```
cd ~/ros2_ws/ ;colcon build --packages-select robot_ur3e_perception --symlink-install; source install/setup.bash; ros2 launch robot_ur3e_perception alt_yolov5_tf.launch.py
```

## 3. For launching the manipulation service server
Set some parameters
```
ros2 param load /joint_trajectory_controller /home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_manipulation/params/goal_precision_sim.yaml
```
```
ros2 param load /moveit_simple_controller_manager /home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_manipulation/params/timeout_allowed.yaml
```
**LAUNCH**
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_manipulation; source install/setup.bash; ros2 launch robot_ur3e_manipulation sim_service_server.launch.py
```
Calling to service to order a coffee
```
ros2 service call /robot_ur3e_manipulation_ss robot_ur3e_manipulation/srv/DeliverCoffeeService 'coffe_order: true'
```

## 4. For launching the Foxglove's bridge
```
cd ~/ros2_ws/ ;colcon build --packages-select robot_ur3e_web;source install/setup.bash; ros2 launch robot_ur3e_web robot_ur3e_web.launch
```
if it is not installed
```
sudo apt-get update; sudo apt-get install ros-humble-foxglove-bridge
```
check the 'ip' of the virtual machine
```
rosbridge_address
```

## 5. Others
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args --remap cmd_vel:=/barista_1/cmd_vel
```
```
ros2 run gazebo_ros spawn_entity.py -file /home/user/ros2_ws/src/coffee-dispenser-project/universal_robot_ros2/the_construct_office_gazebo/models/portable_cup_2/color.sdf -x 14.16 -y -18.19 -z 1.025 -R 1.57 -P 0 -Y 0 -entity cupX
```
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_manipulation; source install/setup.bash; ros2 launch robot_ur3e_manipulation sim_pick_and_place_advanced.launch.py
```
</details>

---

<details>
<summary><b>REAL ROBOT</b></summary>

# REAL ROBOT
## 0. For checking the robot system
Making sure things are going to work
```
ros2 topic echo /joint_states
ros2 topic echo /robot_description
ros2 topic echo /tf
ros2 control list_controllers
ros2 run tf2_ros tf2_echo base_link tool0
ros2 run tf2_tools view_frames
```

## 1. For launching the move_group and rviz nodes
for real arm
```
cd ~/ros2_ws/; colcon build --packages-select real_moveit_config; source ~/ros2_ws/install/setup.bash; ros2 launch real_moveit_config run_moveit.xml
```

## 2. For launching the vision system
Set the environment
```
export PYTHONPATH=$PYTHONPATH:/home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_perception/venv/lib/python3.10/site-packages/
```
```
cd /home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_perception; source venv/bin/activate
```
**LAUNCH**
```
cd ~/ros2_ws/ ;colcon build --packages-select robot_ur3e_perception --symlink-install; source install/setup.bash; ros2 launch robot_ur3e_perception real_yolov5_tf.launch.py
```
optionally
```
ros2 param set /D415/D415 pointcloud.enable true
```

## 3. For launching the manipulation service server
Set some parameters
```
ros2 param load /scaled_joint_trajectory_controller /home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_manipulation/params/goal_precision_real.yaml
```
```
ros2 param load /moveit_simple_controller_manager /home/user/ros2_ws/src/coffee-dispenser-project/robot_ur3e_manipulation/params/timeout_allowed.yaml
```
**LAUNCH**
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_manipulation; source install/setup.bash; ros2 launch robot_ur3e_manipulation real_service_server.launch.py
```
Calling to service to order a coffee
```
ros2 service call /robot_ur3e_manipulation_ss robot_ur3e_manipulation/srv/DeliverCoffeeService 'coffe_order: true'
```

## 4. For launching the Foxglove's bridge
```
cd ~/ros2_ws/ ;colcon build --packages-select robot_ur3e_web;source install/setup.bash; ros2 launch robot_ur3e_web robot_ur3e_web.launch
```
if it is not installed
```
sudo apt-get update; sudo apt-get install ros-humble-foxglove-bridge
```
check the 'ip' of the virtual machine
```
rosbridge_address
```
## 5. Others
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_manipulation; source install/setup.bash; ros2 launch robot_ur3e_manipulation real_pick_and_place_advanced.launch.py
```
</details>

---

<details>
<summary><b>DOCKER</b></summary>

# DOCKER
## Compose
```
docker-compose -f docker-compose-sim.yml up --build
docker-compose -f docker-compose-sim.yml up --build | tee build.log
```
execute a bash of the service
```
docker exec -it container_NAME_server /bin/bash
```

## Build
```
sudo docker build -f starbots-sim-IMAGE -t starbots-sim-IMAGE .
```

## Run
```
docker run --rm -it -p 11311:11311 -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix starbots-sim-gazebo:latest bash
```

## New shell
```
sudo docker exec -it NAME /bin/bash
```

## Clean
```
docker kill $(docker ps -aq) &> /dev/null;
docker container prune -f
docker rmi $(docker images -q) -f
```

## Previous step for visualization
**check display available**
```
ls -la /tmp/.X11-unix/
echo $DISPLAY
```
**remove restrictions to X-server**
```
xhost +local:root
```

## Previous step for Docker 
**installation**
```
sudo apt-get update
sudo apt-get install docker.io docker-compose -y
sudo service docker start
```
**add user to docker-group**
```
sudo usermod -aG docker $USER
newgrp docker
```
</details>

---