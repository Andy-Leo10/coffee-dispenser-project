# coffee-dispenser-project

- [coffee-dispenser-project](#coffee-dispenser-project)
  - [For launching the simulation](#for-launching-the-simulation)
  - [For running the mobile robot](#for-running-the-mobile-robot)

## For launching the simulation
```
source ~/ros2_ws/install/setup.bash
ros2 launch the_construct_office_gazebo starbots_ur3e.launch.xml
```
Making sure joint state topic is working
```
ros2 topic echo /joint_states
```

## For running the mobile robot
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args --remap cmd_vel:=/barista_1/cmd_vel
```
