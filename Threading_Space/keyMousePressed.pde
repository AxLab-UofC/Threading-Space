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
    case 'u':
      animator.untangle();
      break;
  
    case 'f':
      int[][] notes = {{30, 64, 20}, {30, 0, 20}, {30, 63, 20}, {30, 0, 20}, {30, 64, 20}, {30, 0, 20}, {30, 63, 20}, {30, 0, 20}, {30, 64, 20}, 
                       {30, 0, 20}, {30, 63, 20}, {30, 0, 20}, {30, 59, 20}, {30, 0, 20}, {30, 62, 20}, {30, 0, 20}, {30, 60, 20}, {30, 57, 20}};
      midi(0, 1, notes);
      break;
      
    case 'o':
      animator.skip();
      break;
    
   case 'a':
     if (animator.animState == animatorMode.INTERACTIVE);
     animator.startScreensaver();
    break;

    case 'c':
      movePairs(animCircle(0));
      break;
    
    case 'p':
      movePairs(pairCheck());
      break;
    
    case 'd':
      debugMode = !debugMode;
      break;
    
    case 'k':
      ledAll();
      break;
   
    case 'l':
      movePairs(animCircle(0));
      break;
    
    case 's':
      if (animator.status == moveStatus.NONE) {
        animator.start();
      } else {
        animator.stop();
      }
      break;
   
    case 'v':
      visualOn = !visualOn;
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
