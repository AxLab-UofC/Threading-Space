void planPath(int num_x, int num_y, int x_size, int y_size, int x_shift, int y_shift, int num_agents, int num_instances) {
    // Add inputs to python file
    String command = "/opt/homebrew/bin/python3 ";
    String plannerDirectory = "/Users/harrisondong/Desktop/axlab/zorozoro-dev/toio_processing/general_planner_v1.0.1/"; //Enter path to general_planner directory.
    String plannerFile = "Toio_Map_Generator.py";
    String startFile = "start.txt";
    String outputFile = "output_path.txt";
    int y_min_plus_max = 500; // Used to reverse the y-axis to align with path planner (convert 4th quadrant to 1st quadrant).
    
    PrintWriter writer = createWriter(plannerDirectory + startFile);
    HashMap<Integer, Integer> takenVertices = new HashMap<Integer, Integer>(); // Keep track of which vertex is taken.
    
    // ADD CURRENT LOCATIONS TO START FILE
    /*for (int i = 0; i < num_agents; i++) {
        int x = cubes[i].x;
        int y = 500 - cubes[i].y;
        int x_vertex = (int)Math.round((double)(x - x_shift) / (double)x_size * (double)num_x);
        int y_vertex = (int)Math.round((double)(y - y_shift) / (double)y_size * (double)num_y);
        Integer vertex = Integer.valueOf(x_vertex * 10 + y_vertex);
        
        if (takenVertices.containsKey(vertex)) { // Does this need to be more robust? Might need to account for the location of the clashing toio.
            if (!takenVertices.containsKey(vertex + 10)) {
                vertex += 10;
            }
            else if (!takenVertices.containsKey(vertex - 10)) {
                vertex -= 10;
            }
            else if (!takenVertices.containsKey(vertex + 1)) {
                vertex += 1;
            }
            else {
                vertex -= 1;
            }
        }
        
        //int vertex = (int)Math.round(((cubes[i].x - x_shift) * (double)num_x / (double)x_size * (double)num_y) + ((cubes[i].y - 500 + y_shift) * (double)num_y / (double)y_size * -1));
        println("Toio " + i + " is at " + cubes[i].x + ", " + cubes[i].y);
        println("Toio " + i + " is at vertex " + vertex);
        takenVertices.put(vertex, i);
        writer.println(vertex);
    }
    writer.flush();
    writer.close();*/
    
    Command cmd = new Command(command + plannerDirectory + plannerFile + " -a " + Integer.toString(num_x)
                                                                       + " -b " + Integer.toString(num_y)
                                                                       + " -c " + Integer.toString(x_size)
                                                                       + " -d " + Integer.toString(y_size)
                                                                       + " -e " + Integer.toString(x_shift)
                                                                       + " -f " + Integer.toString(y_shift)
                                                                       + " -g " + Integer.toString(num_agents)
                                                                       + " -h " + Integer.toString(num_instances)); // Need to implement start and end locations too.
    
    println("PLANNING PATH!");
    if (cmd.run() == true) {
        println("Done!");
        //println((Object[])cmd.getOutput());
    }
    
    String[] paths = loadStrings(plannerDirectory + outputFile);
    String[][] x_y = new String[num_agents][];
    /**/ArrayList<Integer[]>[] toio_locs = new ArrayList[num_agents]; // Array of Arraylists (one for each toio) of 1x3 Integer Arrays encoding positions (x, y, theta).
    for (int i = 0; i < paths.length; i++) {
        x_y[i] = paths[i].split(",0 ", 0);
    }
    
    for (int i = 0; i < num_agents; i++) {
        /**/toio_locs[i] = new ArrayList<Integer[]>();
        Integer prev_pos[] = new Integer[]{-1,-1,-1};
        char modifying = 'n'; // n -> default; x -> x-coordinate; y -> y-coordinate;
        
        for (int j = 0; j < x_y[i].length; j++) {
            String[] temp = x_y[i][j].split(",", 0);
            Integer[] p = new Integer[]{Integer.parseInt(temp[0]), y_min_plus_max - (Integer.parseInt(temp[1])), 0};
            if (j == x_y[i].length - 1) {
                toio_locs[i].add(p);
                continue;
            }
            if (j == 0) {
                prev_pos[0] = p[0];
                prev_pos[1] = p[1];
                continue;
            }
            if (!p[0].equals(prev_pos[0])) {
                if (modifying != 'x') {
                    if (Integer.compare(p[0], prev_pos[0]) < 0) {
                        prev_pos[2] = 180;
                    }
                    else {
                        prev_pos[2] = 0;
                    }
                    toio_locs[i].add(prev_pos.clone());
                    modifying = 'x';
                }
            }
            else { // !p[1].equals(prev_pos[1])
                if (modifying != 'y') {
                    if (Integer.compare(p[1], prev_pos[1]) < 0) {
                        prev_pos[2] = 270;
                    }
                    else {
                        prev_pos[2] = 90;
                    }
                    toio_locs[i].add(prev_pos.clone());
                    modifying = 'y';
                }
            }
            prev_pos[0] = p[0];
            prev_pos[1] = p[1];
        }
        print("Toio " + i + " locations: ");
        for (Integer[] loc : toio_locs[i]) {
            print(Arrays.toString(loc) + ", ");
        }
        print("\n");
    }
    
    // FIRST LOCATION
    for (int i = 0; i < num_agents; i++) {
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
    }
    
}
