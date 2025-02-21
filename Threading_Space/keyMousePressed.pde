void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      //case UP:
      //  cam.rotateX(PI/2);  
      //  break;
      //case DOWN:
      //  cam.rotateX(-PI/2);
      //  break;
      //case LEFT:
      //  cam.rotateY(PI/4); 
      //  break;
      //case RIGHT:
      //  cam.rotateY(-PI/4);  
      //  break;
      case UP:
        playSpeed += 0.5;  
        break;
      case DOWN:
        playSpeed -= 0.5;  
        break;
      case 11: 
        if (animator.status == moveStatus.NONE) {
          animator.start();
        } else {
          animator.stop();
        }
        break;
    }
  }
  
  switch(key) {
      
    case 'n': // skip the current animation in the sequence
      animator.skip();
      break;
    
   case 'r': // set the system to screensaver mode. If in MSI mode, will run through screensaveranimation before waiting until the next iteration
     if (animator.animState == animatorMode.INTERACTIVE) {
       animator.startScreensaver();
     } else {
       resetVariables();
       animator.reset();
       animator.startScreensaver();
     }
     break;
    
   case 'u': 
      animator.untangle();
      break;

    case 'c':
      movePairs(animCircle(0));
      break;
 
    case 'd': // debug mode
      debugMode = !debugMode;
      setupGUI(); 
      break;
    
    case 'l': // turn off and on the lights (red for bottom, blue for top)
      ledToggle();
      break;
      
   
    case 's': // stop and start the system (i.e. pause)
      if (animator.status == moveStatus.NONE) {
        animator.start();
      } else {
        animator.stop();
      }
      break;
   
    case 'v':
      visualOn = !visualOn;
      break;
      
   case 'p': 
     globalLoading = true; 
     guiChoose = animChoose.PUPPET;
     realChoose = animChoose.PUPPET;
     animator.startInteractive();
     break;
    
  //case 'q': //battery testing
  //  //to be set manually
  //  nCubes = 8;
  //  int time_running = 3; //how long the toios run each time, in minutes
  //  int time_interval = 30; //how long the interval is between calls to actuate toios, in minutes, divisible by time_running
  //  int toio_speed = 50; //remember that it goes in circles
    
  //  table = new Table();
  //  int time_past = 0;
  //  for (int i = 0; i < nCubes; i++) { //assume that the toios start at 100% battery
  //    cubes[i].batteryUpdate(100);
  //  }
    
  //  table.addColumn("Minutes");
    
  //  for (int i = 0; i < nCubes; i++) {
  //    table.addColumn(String.format("Cube %d", cubes[i].id));
  //  }
    
  //  while(true) {
  //    TableRow newRow = table.addRow();
  //    newRow.setInt("Minutes", time_past);
  //    for (int i = 0; i < nCubes; i++) {
  //      newRow.setInt(String.format("Cube %d", cubes[i].id), cubes[i].battery);
  //    }
  //    saveTable(table, "data/battery_report.csv");
      
  //    if (time_past%time_interval == 0) {
  //      for (int i = 0; i < nCubes; i++) {
  //        motorBasic(cubes[i].id, toio_speed, -toio_speed);
  //      }
  //    }
  //    if (time_past%time_interval == time_running) {
  //      for (int i = 0; i < nCubes; i++) {
  //        motorBasic(cubes[i].id, 0, 0);
  //      }
  //    } 
  //    delay(time_running * 60 * 1000); // the length of a cycle, 180000 = 3 minutes
  //    time_past+= time_running;
      
      
  //    //for(int j = 0; j < 50; j++) { //if j < 5 => 30s //j < 50 => 300s = 5min
  //    //  for(int i = 0; i < nCubes; i++) {
  //    //    motorDuration(cubes[i].id, 50, 500);
  //    //  }
  //    //  delay(3000);
  //    //  for(int i = 0; i < nCubes; i++) {
  //    //    motorDuration(cubes[i].id, -50, 500);
  //    //  }
  //    //  delay(3000);
  //    //}
  //    //delay(1500000); //can increase if desired a more extensive run - i.e. with waiting period
  //  }
     
    
    default:
      break;
    
  }
}

DiscreteSequence seq;
SmoothSequence smooth;

void mousePressed() {
}

void mouseReleased() {
}
