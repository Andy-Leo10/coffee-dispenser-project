# coffee-dispenser-project

- [coffee-dispenser-project](#coffee-dispenser-project)
  - [For launching the simulation](#for-launching-the-simulation)

## For launching the simulation
```
source ~/ros2_ws/install/setup.bash
ros2 launch the_construct_office_gazebo starbots_ur3e.launch.xml
```
Making sure joint state topic is working
```
ros2 topic echo /joint_states
```
