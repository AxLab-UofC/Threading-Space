# What is Threading Space?
Threading Space is a kinetic sculpture that explores how spatial perception can be transformed by dynamically and geometrically reconfiguring physical lines of thread. As the threads in motion interact, they become a hypnotic medium for three-dimensional patterns. Through a physical installation and an interactive GUI, Threading Space invites the audience to explore the potential of using swarm robots and line elements to create, morph, and interact with space.

# How does Threading Space Work?
The Core loop of Threading Space is:
- The Animation System calculates the posistions of the toios
- Using `motorVelocityTarget`, a new velocity is sent to the toios based on their current and target posistions/velocities
- The Visualization and GUI is updated based on the new expected and actual locations of the toios

# Core Animation System
The core animation system accepts two kinds of sequences:
- Uninteractive sequences, which output a 2D or 3D set of points based on a time `t` in milliseconds. There are two types of uninteractive sequences:
  - Smooth Sequences, which continously move for a period of time
  - Discrete Sequences, which consist of a set of frames. The path-finding mechanism automatically generates a Discrete sequence to move between two sets of points.
- Interactive sequences, which output a 2D or 3D set of points based on input from the user.

Using an input function, the core animation system allows for
- Queuing animations
- Pausing and resuming animations
- If an sequence is supposed to tangle, the animation can be played in reverse to automatically untangle.

# Files
- Main
  - `Path_Planning`: Runs the command to generate the path planning
  - `keyMousePressed`: Manages any key presses or mouse events
  - `Threading_Space`: Manages the main loop
 
- The Animation System
  - `Animation_Manager`: Controls the flow between different animations
  - `anim_interactive`: Manages the Interactive animations: Each interactive animation has a set of variables that the user can change in real-time
  - `Anim_Cylinder`: An Interactive animation that has a cylinder at the top and on the bottom
  - `Anim_Line`:  An Interactive animation that has a line at the top and on the bottom
  - `Anim_Screensaver`:  Contains all the non-interactive animations

- Visualization
  - `visual`: Manages the 3D positions of the cubes in the visualization. This allows for the visualization of threading space to be synced or independant from their physical locations.
  - `display`: Contains the 3d components that make up the threading space visualization
  - `gui`: Manages the interactive aspects of the GUI, (i.e. the buttons)
 
- Toio and OSC Management:
  - `Cube`:  Stores the Cube class, which abstracts away the lower level communication with the toios
  - `pair`: Stores the Pair class, which manages pairs of cubes at once
  - `MotorTargetVel`: Stores the `motorTargetVelocity` command which will use PID to smoothly follow a moving target
  - `oscRecieve`: Manages all received OSC messages
  - `oscSend`: Sends OSC Messages


The Full Laptop-Toio Documnentation can be found [here](https://github.com/AxLab-UofC/Laptop-TOIO)
