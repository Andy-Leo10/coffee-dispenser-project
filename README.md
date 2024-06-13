# coffee-dispenser-project

- [coffee-dispenser-project](#coffee-dispenser-project)
  - [0. For launching the simulation](#0-for-launching-the-simulation)
  - [1. For launching the move\_group and rviz nodes](#1-for-launching-the-move_group-and-rviz-nodes)
  - [2. For launching the vision system](#2-for-launching-the-vision-system)
  - [3. For launching the manipulation service server](#3-for-launching-the-manipulation-service-server)
  - [4. For launching the Foxglove's bridge](#4-for-launching-the-foxgloves-bridge)
  - [z. or running the mobile robot](#z-or-running-the-mobile-robot)

## 0. For launching the simulation
```
source ~/ros2_ws/install/setup.bash; ros2 launch the_construct_office_gazebo starbots_ur3e.launch.xml
```
Making sure joint state topic is working
```
ros2 topic echo /joint_states
```

## 1. For launching the move_group and rviz nodes
```
cd ~/ros2_ws/; colcon build --packages-select sim_moveit_config; source ~/ros2_ws/install/setup.bash; ros2 launch sim_moveit_config run_moveit.xml
```

## 2. For launching the vision system
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_perception; source install/setup.bash; ros2 launch robot_ur3e_perception camera_tf.launch.py
```

## 3. For launching the manipulation service server
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

## z. or running the mobile robot
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args --remap cmd_vel:=/barista_1/cmd_vel
```
