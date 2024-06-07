# coffee-dispenser-project

- [coffee-dispenser-project](#coffee-dispenser-project)
  - [For launching the simulation](#for-launching-the-simulation)
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

## For launching the manipulation action server 
```
cd ~/ros2_ws/; colcon build --packages-select robot_ur3e_manipulation; source install/setup.bash; ros2 launch robot_ur3e_manipulation sim_action_server.launch.py
```
Calling to action to order a coffee
```
ros2 action send_goal /robot_ur3e_manipulation_as robot_ur3e_manipulation/action/DeliverCoffeeAction 'coffe_order: true' -f
```

## For running the mobile robot
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args --remap cmd_vel:=/barista_1/cmd_vel
```
