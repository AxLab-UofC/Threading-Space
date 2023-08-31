// Inputs for python file
String DEBUG = "False";

String command = "/opt/homebrew/bin/python3 ";
String plannerDirectory = "/Users/harrisondong/Desktop/axlab/Threading-Space/general_planner_v1.0.1/"; //Enter path to general_planner directory.
String plannerFile = "Toio_Map_Generator.py";
String startFile = "start.txt";
String goalFile = "goal.txt";
String outputFile = "output_path.txt";
int num_agents = nPairs;

int y_min_plus_max = ymin + ymax; // Used to reverse the y-axis to align with path planner (convert 4th quadrant to 1st quadrant).


// USES CURRENT TOIO LOCATIONS AS START POSITIONS
ArrayList<Frame> planPath(int targets[][]) {
  PrintWriter start_writer = createWriter(plannerDirectory + startFile);
  HashMap<Integer, Integer> takenVertices = new HashMap<Integer, Integer>(); // Keep track of which vertex is taken.

  // ADD CURRENT LOCATIONS TO START FILE
  for (int i = 0; i < num_agents; i++) {
    int x = cubes[i].x;
    int y = cubes[i].y;
    int x_vertex = (int)Math.round((double)(x - x_shift) / (double)x_size * (double)num_x);
    int y_vertex = (int)Math.round((double)(y - y_shift) / (double)y_size * (double)num_y);
    Integer vertex = Integer.valueOf(x_vertex * num_x + y_vertex);

    if (takenVertices.containsKey(vertex)) { // Does this need to be more robust? Might need to account for the location of the clashing toio.
      if (!takenVertices.containsKey(vertex + 10)) {
        vertex += 10;
      } else if (!takenVertices.containsKey(vertex - 10)) {
        vertex -= 10;
      } else if (!takenVertices.containsKey(vertex + 1)) {
        vertex += 1;
      } else {
        vertex -= 1;
      }
    }

    //int vertex = (int)Math.round(((cubes[i].x - x_shift) * (double)num_x / (double)x_size * (double)num_y) + ((cubes[i].y - 500 + y_shift) * (double)num_y / (double)y_size * -1));
    //println("Toio " + i + " is at " + cubes[i].x + ", " + cubes[i].y);
    //println("Toio " + i + " is at vertex " + vertex);
    takenVertices.put(vertex, i);
    start_writer.println(vertex);
  }
  start_writer.flush();
  start_writer.close();

  // ADD GOAL LOCATIONS TO GOAL FILE
  PrintWriter goal_writer = createWriter(plannerDirectory + goalFile);

  for (int i = 0; i < num_agents; i++) {
    int x_vertex = (int)Math.round((double)(targets[i][0] - x_shift) / (double)x_size * (double)num_x);
    int y_vertex = (int)Math.round((double)(targets[i][1] - y_shift) / (double)y_size * (double)num_y);
    Integer vertex = Integer.valueOf(x_vertex * num_x + y_vertex);

    goal_writer.println(vertex);
  }
  goal_writer.flush();
  goal_writer.close();

  return runPlanner();
}


// FOR PREDETERMINED START POSITIONS
ArrayList<Frame> planPath(int starts[][], int targets[][]) {

  PrintWriter start_writer = createWriter(plannerDirectory + startFile);

  // ADD START LOCATIONS TO START FILE
  for (int i = 0; i < num_agents; i++) {
    int x_vertex = (int)Math.round((double)(starts[i][0] - x_shift) / (double)x_size * (double)num_x);
    int y_vertex = (int)Math.round((double)(starts[i][1] - y_shift) / (double)y_size * (double)num_y);
    Integer vertex = Integer.valueOf(x_vertex * num_x + y_vertex);
    start_writer.println(vertex);
  }
  start_writer.flush();
  start_writer.close();

  // ADD GOAL LOCATIONS TO GOAL FILE
  PrintWriter goal_writer = createWriter(plannerDirectory + goalFile);

  for (int i = 0; i < num_agents; i++) {
    int x_vertex = (int)Math.round((double)(targets[i][0] - x_shift) / (double)x_size * (double)num_x);
    int y_vertex = (int)Math.round((double)(targets[i][1] - y_shift) / (double)y_size * (double)num_y);
    Integer vertex = Integer.valueOf(x_vertex * num_x + y_vertex);

    goal_writer.println(vertex);
  }
  goal_writer.flush();
  goal_writer.close();

  return runPlanner();
}


// RUN PYTHON FILE
ArrayList<Frame> runPlanner() {
  Command cmd = new Command(command + plannerDirectory + plannerFile
    + " -a " + Integer.toString(num_x)
    + " -b " + Integer.toString(num_y)
    + " -c " + Integer.toString(x_size)
    + " -d " + Integer.toString(y_size)
    + " -e " + Integer.toString(x_shift)
    + " -f " + Integer.toString(y_shift)
    + " -g " + Integer.toString(num_agents)
    + " -h " + Integer.toString(num_instances)
    + " -i " + plannerDirectory
    + " -j " + DEBUG); // Need to implement start and end locations too.

  println("PLANNING PATH!");
  if (cmd.run() == true) {
    println("Done!");
  }
  else {
    println("Path Planner Failed!");
    ArrayList<Frame> frames = new ArrayList<Frame>();
    return frames;
  }

  String[] paths = loadStrings(plannerDirectory + outputFile);
  String[][] x_y = new String[num_agents][];
  /**/  ArrayList<Integer[]>[] toio_locs = new ArrayList[num_agents]; // Array of Arraylists (one for each toio) of 1x3 Integer Arrays encoding positions (x, y, theta).
  for (int i = 0; i < paths.length; i++) {
    x_y[i] = paths[i].split(",0 ", 0);
  }

  for (int i = 0; i < num_agents; i++) {
    /**/    toio_locs[i] = new ArrayList<Integer[]>();
    Integer prev_pos[] = new Integer[]{-1, -1, -1};

    for (int j = 0; j < x_y[i].length + 1; j++) {
      if (j == x_y[i].length) {
        toio_locs[i].add(prev_pos.clone());
        continue;
      }
      
      String[] temp = x_y[i][j].split(",", 0);
      Integer[] p = new Integer[]{Integer.parseInt(temp[0]), Integer.parseInt(temp[1]), 0};
      
      if (j == 0) {
        prev_pos = p;
        continue;
      }

      if (p[0].intValue() < prev_pos[0].intValue()) {
        prev_pos[2] = 180;
      } else if (p[0].intValue() > prev_pos[0].intValue()) {
        prev_pos[2] = 0;
      } else if (p[1].intValue() < prev_pos[1].intValue()) {
        prev_pos[2] = 90;
      } else {
        prev_pos[2] = 270;
      }
      toio_locs[i].add(prev_pos.clone());
      prev_pos = p;
    }
    print("Toio " + i + " locations: ");
    for (Integer[] loc : toio_locs[i]) {
      print(Arrays.toString(loc) + ", ");
    }
    print("\n");
  }

  // Add to Animation
  boolean done = false;
  ArrayList<Frame> frames = new ArrayList<Frame>();
  //seq.setSpeed(200);
  while (!done) {
    int planned_path[][] = new int[num_agents][];
    done = toio_locs[0].size() == 1;
    for (int i = 0; i < num_agents; i++) {
      Integer temp[];
      done &= toio_locs[i].size() == 1;
      if (toio_locs[i].size() == 1) {
        temp = toio_locs[i].get(0);
      } else {
        temp = toio_locs[i].remove(0);
      }
      planned_path[i] = Arrays.asList(temp).stream().mapToInt(Integer::intValue).toArray();
    }
    if (!done) {
      println("adding frame to seq");
      for (int[] toio : planned_path) {
        println(Arrays.toString(toio));
      }
      frames.add(new Frame(moveType.BOTTOM, planned_path));
    }
  }

  //println("adding seq to animator");
  return frames;


  // FIRST LOCATION
  /*for (int i = 0; i < num_agents; i++) {
   motorTarget(cubes[i].id, 2, toio_locs[i].get(0)[0], toio_locs[i].get(0)[1], toio_locs[i].get(0)[2]);
   delay(2000);
   }
   delay(1500);
   
   // REST OF LOCATIONS
   int startTime = millis();
   while(true) {
   boolean done = toio_locs[0].isEmpty();
   
   for (int i = 0; i < num_agents; i++) {
   done &= toio_locs[i].isEmpty();
   if (toio_locs[i].isEmpty()) {
   //println("Toio " + i + " empty.");
   continue;
   }
   
   if (Math.abs(cubes[i].x - toio_locs[i].get(0)[0]) < 10 && Math.abs(cubes[i].y - toio_locs[i].get(0)[1]) < 10) {
   toio_locs[i].remove(0);
   if (toio_locs[i].isEmpty()) {
   continue;
   }
   println("Moving " + i + " to " + toio_locs[i].get(0)[0] + ", " + toio_locs[i].get(0)[1] + " at " + toio_locs[i].get(0)[2] + " degrees.");
   motorTarget(cubes[i].id, 2, toio_locs[i].get(0)[0], toio_locs[i].get(0)[1], toio_locs[i].get(0)[2]);
   
   }
   }
   
   if (done) {
   println("Stopping path execution. DONE!");
   break;
   }
   if (millis() - startTime > 15000) {
   println("Stopping path execution. TIMEOUT!");
   break;
   }
   }*/
}
