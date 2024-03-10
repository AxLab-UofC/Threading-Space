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
      
    case 'n':
      animator.skip();
      break;
    
   case 'r':
     if (animator.animState == animatorMode.INTERACTIVE);
     animator.startScreensaver();
      break;

    case 'c':
      movePairs(animCircle(0));
      break;
 
    case 'd':
      debugMode = !debugMode;
      setupGUI(); 
      break;
    
    case 'l':
      ledToggle();
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
      
   case 'p':
     globalLoading = true; 
     realChoose = animChoose.PUPPET;
     animator.startInteractive();
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
