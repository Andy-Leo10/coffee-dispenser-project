
- [**`FollowJointTrajectory` action message structure**](#followjointtrajectory-action-message-structure)
  - [📊 **Goal Message**](#-goal-message)
    - [**1. Trajectory `trajectory_msgs/JointTrajectory`**](#1-trajectory-trajectory_msgsjointtrajectory)
    - [**2. Tolerances**](#2-tolerances)
      - [**`path_tolerance[]`** - During motion](#path_tolerance---during-motion)
      - [**`goal_tolerance[]`** - At final position](#goal_tolerance---at-final-position)
      - [**`goal_time_tolerance`** - Extra time allowed](#goal_time_tolerance---extra-time-allowed)
  - [🎯 **Result Message**](#-result-message)
  - [📡 **Feedback Message**](#-feedback-message)
  - [**Examples**](#examples)
    - [Trajectory with pauses at waypoints](#trajectory-with-pauses-at-waypoints)
    - [Trajectory with realistic motion profiles](#trajectory-with-realistic-motion-profiles)
- [**What MoveIt Does For You?**](#what-moveit-does-for-you)

# **`FollowJointTrajectory` action message structure**

For `control_msgs/action/FollowJointTrajectory`:

```
┌──────────────────────────────────────────────────────────────────┐
│ PART 1: GOAL (above the first ---) - What to execute             │
├──────────────────────────────────────────────────────────────────┤
│ • trajectory: The joint positions over time                      │
│ • multi_dof_trajectory: For floating/planar joints (rarely used) │
│ • path_tolerance: How much deviation allowed during motion       │
│ • goal_tolerance: How close to final position is "success"       │
│ • goal_time_tolerance: Extra time allowed to reach goal          │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ PART 2: RESULT (between first and second ---) - Final status     │
├──────────────────────────────────────────────────────────────────┤
│ • error_code: Integer status (0=success, negative=failure)       │
│ • error_string: Human-readable explanation                       │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ PART 3: FEEDBACK (after second ---) - Continuous updates         │
├──────────────────────────────────────────────────────────────────┤
│ • header: Timestamp of this feedback                             │
│ • joint_names: Which joints are being tracked                    │
│ • desired: Where robot should be at this moment                  │
│ • actual: Where robot actually is                                │
│ • error: Difference (desired - actual)                           │
└──────────────────────────────────────────────────────────────────┘
```


## 📊 **Goal Message**

Let me explain the most important parts:

### **1. Trajectory `trajectory_msgs/JointTrajectory`**

This is the **core** - the actual motion plan:

```yaml
trajectory:
  header:
    stamp: {sec: 0, nanosec: 0}  # Start time (0 = start immediately)
    frame_id: ''                  # Reference frame (usually empty for joint space)
  
  joint_names: 
    - shoulder_pan_joint
    - shoulder_lift_joint
    - elbow_joint
    - wrist_1_joint
    - wrist_2_joint
    - wrist_3_joint
  
  points:
    # Waypoint 1 (start position)
    - positions: [0.0, -1.57, 0.0, -1.57, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      accelerations: []
      effort: []
      time_from_start: {sec: 0, nanosec: 0}
    
    # Waypoint 2 (intermediate)
    - positions: [0.5, -1.2, 0.3, -1.4, 0.0, 0.0]
      velocities: [0.3, 0.2, 0.15, 0.1, 0.0, 0.0]
      time_from_start: {sec: 1, nanosec: 500000000}  # 1.5 seconds
    
    # Waypoint 3 (final position)
    - positions: [1.0, -0.8, 0.6, -1.2, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]  # Stop at end
      time_from_start: {sec: 3, nanosec: 0}  # 3 seconds total
```

**Key concepts:**
- `positions[]`: Must match length of `joint_names[]`
- `time_from_start`: Time since trajectory start when this waypoint should be reached
- `velocities[]`, `accelerations[]`: Optional but recommended for smooth motion
- Controller **interpolates** between waypoints

### **2. Tolerances**

#### **`path_tolerance[]`** - During motion
```yaml
path_tolerance:
  - name: "elbow_joint"
    position: 0.1      # Can deviate ±0.1 rad during motion
    velocity: 0.5      # Can deviate ±0.5 rad/s
    acceleration: 2.0  # Can deviate ±2.0 rad/s²
```
If violated → **PATH_TOLERANCE_VIOLATED** (aborts immediately)

#### **`goal_tolerance[]`** - At final position
```yaml
goal_tolerance:
  - name: "shoulder_pan_joint"
    position: 0.01     # Must be within ±0.01 rad of final position
    velocity: 0.01     # Must be nearly stopped
    acceleration: 0.0  # Usually ignored
```
If violated → **GOAL_TOLERANCE_VIOLATED** (after goal_time_tolerance expires)

#### **`goal_time_tolerance`** - Extra time allowed
```yaml
goal_time_tolerance: {sec: 0, nanosec: 500000000}  # +0.5 seconds allowed
```

**Example scenario:**
- Trajectory says: "reach final position at t=3.0s"
- `goal_time_tolerance` = 0.5s
- Robot has until t=3.5s to be within `goal_tolerance`

---

## 🎯 **Result Message**

```cpp
int32 SUCCESSFUL = 0                 // ✓ Reached goal within tolerances
int32 INVALID_GOAL = -1              // ✗ Goal was malformed (e.g., past timestamp)
int32 INVALID_JOINTS = -2            // ✗ Joint names don't match controller
int32 OLD_HEADER_TIMESTAMP = -3      // ✗ Trajectory start time is in the past
int32 PATH_TOLERANCE_VIOLATED = -4   // ✗ Deviated too much during motion
int32 GOAL_TOLERANCE_VIOLATED = -5   // ✗ Didn't reach final position accurately
```

**`error_string`** provides details:
```
"Joint 'elbow_joint' exceeded path tolerance by 0.15 rad at t=1.2s"
```

---

## 📡 **Feedback Message**

Published at **controller rate** (typically 100 Hz):

```yaml
# Example feedback at t=1.5 seconds into motion
header:
  stamp: {sec: 1234567, nanosec: 500000000}
  frame_id: ''

joint_names: [shoulder_pan_joint, shoulder_lift_joint, ...]

desired:  # Where you SHOULD be (from trajectory interpolation)
  positions: [0.5, -1.2, 0.3, -1.4, 0.0, 0.0]
  velocities: [0.3, 0.2, 0.15, 0.1, 0.0, 0.0]
  time_from_start: {sec: 1, nanosec: 500000000}

actual:  # Where you ACTUALLY are (from /joint_states)
  positions: [0.52, -1.18, 0.31, -1.39, 0.01, 0.0]
  velocities: [0.31, 0.19, 0.16, 0.09, 0.01, 0.0]
  time_from_start: {sec: 1, nanosec: 500000000}

error:  # Tracking error (desired - actual)
  positions: [-0.02, -0.02, -0.01, -0.01, -0.01, 0.0]
  velocities: [-0.01, 0.01, -0.01, 0.01, -0.01, 0.0]
```

## **Examples**

### Trajectory with pauses at waypoints
```
ros2 action send_goal /joint_trajectory_controller/follow_joint_trajectory control_msgs/action/FollowJointTrajectory "
trajectory:
  header:
    stamp:
      sec: 0
      nanosec: 0
    frame_id: ''
  joint_names:
    - shoulder_pan_joint
    - shoulder_lift_joint
    - elbow_joint
    - wrist_1_joint
    - wrist_2_joint
    - wrist_3_joint
  points:
    - positions: [1.0, -0.8, 0.6, -1.2, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 0, nanosec: 0}
    - positions: [0.5, -1.2, 0.3, -1.4, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 2, nanosec: 0}
    - positions: [0.5, -1.2, 0.3, -1.4, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 4, nanosec: 0}
    - positions: [0.0, -1.57, 0.0, -1.57, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 6, nanosec: 0}
    - positions: [0.0, -1.57, 0.0, -1.57, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 8, nanosec: 0}
    - positions: [1.0, -0.8, 0.6, -1.2, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 10, nanosec: 0}
path_tolerance:
  - {name: 'shoulder_pan_joint', position: 0.1, velocity: 0.5, acceleration: 0.0}
  - {name: 'shoulder_lift_joint', position: 0.1, velocity: 0.5, acceleration: 0.0}
  - {name: 'elbow_joint', position: 0.1, velocity: 0.5, acceleration: 0.0}
  - {name: 'wrist_1_joint', position: 0.1, velocity: 0.5, acceleration: 0.0}
  - {name: 'wrist_2_joint', position: 0.1, velocity: 0.5, acceleration: 0.0}
  - {name: 'wrist_3_joint', position: 0.1, velocity: 0.5, acceleration: 0.0}
goal_tolerance: []
goal_time_tolerance: {sec: 1, nanosec: 0}
```

### Trajectory with realistic motion profiles
```
ros2 action send_goal /joint_trajectory_controller/follow_joint_trajectory control_msgs/action/FollowJointTrajectory "
trajectory:
  header:
    stamp: {sec: 0, nanosec: 0}
    frame_id: ''
  joint_names:
    - shoulder_pan_joint
    - shoulder_lift_joint
    - elbow_joint
    - wrist_1_joint
    - wrist_2_joint
    - wrist_3_joint
  points:
    # Point 0: Start position (rest)
    - positions: [1.0, -0.8, 0.6, -1.2, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      accelerations: [0.5, 0.4, 0.3, 0.3, 0.0, 0.0]
      time_from_start: {sec: 0, nanosec: 0}
    
    # Point 1: Accelerating phase (25% of motion)
    - positions: [0.875, -0.9, 0.525, -1.25, 0.0, 0.0]
      velocities: [0.25, 0.2, 0.15, 0.1, 0.0, 0.0]
      accelerations: [0.5, 0.4, 0.3, 0.3, 0.0, 0.0]
      time_from_start: {sec: 0, nanosec: 500000000}
    
    # Point 2: Cruising phase (max velocity)
    - positions: [0.625, -1.1, 0.375, -1.35, 0.0, 0.0]
      velocities: [0.5, 0.4, 0.3, 0.3, 0.0, 0.0]
      accelerations: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 1, nanosec: 0}
    
    # Point 3: Decelerating to waypoint (smooth transition)
    - positions: [0.5, -1.2, 0.3, -1.4, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      accelerations: [-0.5, -0.4, -0.3, -0.3, 0.0, 0.0]
      time_from_start: {sec: 2, nanosec: 0}
    
    # Point 4: Re-accelerating in new direction
    - positions: [0.375, -1.285, 0.225, -1.435, 0.0, 0.0]
      velocities: [-0.25, -0.17, -0.15, -0.07, 0.0, 0.0]
      accelerations: [-0.5, -0.34, -0.3, -0.14, 0.0, 0.0]
      time_from_start: {sec: 2, nanosec: 500000000}
    
    # Point 5: Cruising to next waypoint
    - positions: [0.125, -1.455, 0.075, -1.505, 0.0, 0.0]
      velocities: [-0.5, -0.37, -0.3, -0.15, 0.0, 0.0]
      accelerations: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 3, nanosec: 500000000}
    
    # Point 6: Decelerating to final waypoint
    - positions: [0.0, -1.57, 0.0, -1.57, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      accelerations: [0.5, 0.23, 0.3, -0.13, 0.0, 0.0]
      time_from_start: {sec: 4, nanosec: 500000000}
    
    # Point 7: Accelerating back
    - positions: [0.25, -1.3425, 0.15, -1.435, 0.0, 0.0]
      velocities: [0.5, 0.455, 0.3, 0.27, 0.0, 0.0]
      accelerations: [0.5, 0.455, 0.3, 0.27, 0.0, 0.0]
      time_from_start: {sec: 5, nanosec: 500000000}
    
    # Point 8: Cruising home
    - positions: [0.625, -1.0275, 0.375, -1.2525, 0.0, 0.0]
      velocities: [0.75, 0.63, 0.45, 0.365, 0.0, 0.0]
      accelerations: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      time_from_start: {sec: 6, nanosec: 500000000}
    
    # Point 9: Final deceleration to rest
    - positions: [1.0, -0.8, 0.6, -1.2, 0.0, 0.0]
      velocities: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      accelerations: [-0.75, -0.63, -0.45, -0.365, 0.0, 0.0]
      time_from_start: {sec: 8, nanosec: 0}
path_tolerance: []
goal_tolerance: []
goal_time_tolerance: {sec: 0, nanosec: 500000000}
" --feedback
```

# **What MoveIt Does For You?**

When you use `move_group_arm->plan()` and `execute()`, MoveIt:

1. **Generates the trajectory** (OMPL planning + smoothing)
2. **Fills in all the fields** (positions, velocities, accelerations, time stamps)
3. **Sets appropriate tolerances** (from your SRDF configuration)
4. **Sends the FollowJointTrajectory goal** to the controller
5. **Monitors feedback** and handles errors

So you don't have to manually construct all this complex message structure!
