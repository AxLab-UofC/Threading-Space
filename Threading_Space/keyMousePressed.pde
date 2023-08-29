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

  case 'f':
    int[][] notes = {{30, 64, 20}, {30, 63, 20}, {30, 64, 20}, {30, 63, 20}, {30, 64, 20}, {30, 63, 20}, {30, 59, 20}, {30, 62, 20}, {30, 60, 20}, {30, 57, 20}};
    midi(0, 1, notes);
    break;
    
   case 'a':
    break;
    
   case 'b':
    visualize(getCircle(0));
    break;
    
    case 'c':
    movePairs(getCircle(0));
    break;
    
    case 'd':
    debugMode = !debugMode;
    break;
    
    case 'g':
    guiOn = !guiOn;
    break;
    
    case 'k':
    ledAll();
    break;
   
    case 'l':
    movePairs(getLine(0));
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
