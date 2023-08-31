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
      
    }
  }
  
  switch(key) {
    
  case 'u':
    animator.untangle();
    break;
    

  case 'f':
    int[][] notes = {{30, 64, 20}, {30, 0, 20}, {30, 63, 20}, {30, 0, 20}, {30, 64, 20}, {30, 0, 20}, {30, 63, 20}, {30, 0, 20}, {30, 64, 20}, 
                     {30, 0, 20}, {30, 63, 20}, {30, 0, 20}, {30, 59, 20}, {30, 0, 20}, {30, 62, 20}, {30, 0, 20}, {30, 60, 20}, {30, 57, 20}};
    midi(0, 1, notes);
    break;
    
   case 'a':
    break;

    case 'c':
    movePairs(animCircle(0));
    break;
    
    case 'p':
    seq = new DiscreteSequence();
    seq.frames = planPath(animCircle(0));
    animator.stop();
    animator.clear();
    animator.add(seq);
    animator.start();
    //movePairs(pairCheck());
    break;
    
    case 'd':
    debugMode = !debugMode;
    break;
    
    //case 'g':
    //guiOn = !guiOn;
    //break;
    
    case 'k':
    ledAll();
    break;
   
    case 'l':
    movePairs(animLine(0));
    break;
    
    case 's':
    if (animator.status == moveStatus.NONE) {
      animator.start();
    } else {
      stop();
      animator.stop();
    }
    break;
   
    case 'v':
    visualOn = !visualOn;
    break;
  
     //case 'x':
     //guiChoose = GUI.WAVE;
     //setupGUI(); 
     //break; 
     
     case 'y':
     guiChoose = GUI.CYLINDER;
     setupGUI(); 
     break; 
     
     case 'z':
     guiChoose = GUI.LINE;
     setupGUI(); 
     break; 
  case 'm':
    int targets[][] = new int[nPairs][2];
    targets[0][0] = 190;
    targets[0][1] = 270;
    targets[1][0] = 110;
    targets[1][1] = 390;
    targets[2][0] = 270;
    targets[2][1] = 190;
    targets[3][0] = 310;
    targets[3][1] = 350;
    targets[4][0] = 190;
    targets[4][1] = 430;
    targets[5][0] = 390;
    targets[5][1] = 430;
    planPath(targets);
    if (animator.status == moveStatus.NONE) {
      animator.start();
    } else {
      println("moveStatus not NONE");
      stop();
      animator.stop();
    }
    break;
    
    
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
