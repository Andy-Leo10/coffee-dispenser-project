# coffee-dispenser-project

- [coffee-dispenser-project](#coffee-dispenser-project)
  - [For launching the simulation](#for-launching-the-simulation)
  - [For launching the move\_group and rviz nodes](#for-launching-the-move_group-and-rviz-nodes)
  - [For launching the vision system](#for-launching-the-vision-system)
  - [For launching the manipulation service server](#for-launching-the-manipulation-service-server)
  - [For running the mobile robot](#for-running-the-mobile-robot)

## For launching the simulation
```
source ~/ros2_ws/install/setup.bash; ros2 launch the_construct_office_gazebo starbots_ur3e.launch.xml
```
Making sure joint state topic is working
```
ros2 topic echo /joint_states
```

## For launching the move_group and rviz nodes
```
source ~/ros2_ws/install/setup.bash; ros2 launch sim_moveit_config run_moveit.xml
```

## For launching the vision system
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_perception; source install/setup.bash; ros2 launch robot_ur3e_perception camera_tf.launch.py
```

## For launching the manipulation service server
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_manipulation; source install/setup.bash; ros2 launch robot_ur3e_manipulation sim_service_server.launch.py
```
Calling to service to order a coffee
```
ros2 service call /robot_ur3e_manipulation_ss robot_ur3e_manipulation/srv/DeliverCoffeeService 'coffe_order: true'
```

## For running the mobile robot
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args --remap cmd_vel:=/barista_1/cmd_vel
```
