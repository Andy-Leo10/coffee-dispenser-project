# Control Commands

This document provides example ROS2 commands to control the coffee dispenser robot's gripper and arm using action servers.

## Move the gripper to a specific position
```
ros2 action send_goal /gripper_controller/gripper_cmd control_msgs/action/GripperCommand "{command: {position: 0.8, max_effort: 10.0}}" --feedback
```

## Move the arm to a specific joint configuration

```
ros2 topic pub --once /joint_trajectory_controller/joint_trajectory trajectory_msgs/msg/JointTrajectory "{
  joint_names: ['shoulder_pan_joint', 'shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'],
  points: [
    {
      positions: [0.0, -1.57, 1.57, -1.57, -1.57, 0.0],
      time_from_start: {sec: 2, nanosec: 0}
    }
  ]
}"
```

```
ros2 action send_goal /joint_trajectory_controller/follow_joint_trajectory control_msgs/action/FollowJointTrajectory "
trajectory:
  joint_names: [shoulder_pan_joint, shoulder_lift_joint, elbow_joint, wrist_1_joint, wrist_2_joint, wrist_3_joint]
  points:
  - positions: [0.5, -1.0, -1.5, -1.0, 0.0, 0.0]
    time_from_start: {sec: 2, nanosec: 0}
" --feedback
```
