# Files
- Toio and OSC Management:
  - `Cube`:  Stores the Cube class, which abstracts away the lower level communication with the toios
  - `pair`: Stores the Pair class, which manages pairs of cubes at once
  - `MotorTargetVel`: Stores the `motorTargetVelocity` command which will use PID to smoothly follow a moving target
  - `oscRecieve`: Manages all received OSC messages
  - `oscSend`: Sends OSC Messages

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

- Main
  - `Path_Planning`: Runs the command to generate the path planning
  - `keyMousePressed`: Manages any key presses or mouse events
  - `Threading_Space`: Manages the main loop
 
The Full Laptop-Toio Documnentation can be found [here](https://github.com/AxLab-UofC/Laptop-TOIO)

# How does Threading Space Work?

The Core loop of Threading Space is:
- The Animation System calculates the posistions of the toios
- Using `motorVelocityTarget`, a new velocity is sent to the toios based on their current and target posistions/velocities
- The Visualization and GUI is updates
