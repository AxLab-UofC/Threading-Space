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
     is_paused = false;
     // first_time = true; //i set this to false later
     if (animator.animState == animatorMode.INTERACTIVE) {
       animator.startScreensaver();
     } else {
       resetVariables();
       animator.reset();
       animator.startScreensaver();
     }
     break;
   
    case 'd': // debug mode, shows important info including next runtime
      debugMode = !debugMode;
      setupGUI(); 
      break;
   
    case 'l': // turn off and on the lights (red for bottom, blue for top)
      ledToggle();
      break;
    
   
    case 's': // stop and start the system (i.e. pause)
      if (animator.status == moveStatus.NONE) {
        animator.start();
        is_paused = false;
      } else {
        animator.stop();
        is_paused = true;
      }
      break;
   
    // these options are not very useful:
    case 'v':
      visualOn = !visualOn;
      break;
   case 'u': 
      animator.untangle();
      break;

    case 'c':
      movePairs(animCircle(0));
      break;
     
   case 'p': 
     globalLoading = true; 
     guiChoose = animChoose.PUPPET;
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
