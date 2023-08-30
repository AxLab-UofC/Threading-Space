import peasy.PeasyCam;
PeasyCam cam;


import oscP5.*;
import netP5.*;

import java.util.*;

//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection
int nCubes = 20;
int nPairs = 10;
int cubesPerHost = 20;
int maxMotorSpeed = 115;

//server ids
String[] hosts = {"127.0.0.1","169.254.0.2"};


//For testing on small mat
boolean testMode = false;


//Enable and Disable Zorozoro
boolean zorozoro = false;
int[][] zoropairs = {{185, 137}, {105, 171}, {118, 92}, {190, 145}, {127, 144}, {172, 148}};

//For Visualizing Posistions and Debug mode in GUI
boolean debugMode = false;
boolean visualOn = true; 
PairVisual[] pairsViz;

//for Threading Space Visualization
int xmin = 34;
int ymin = 35;
int xmax = 949;
int ymax = 898;
int vert = 500;


int xmid = (int) (xmax + xmin)/2;
int ymid = (int) (ymax + ymin)/2;

//For Path Planning
int num_x = 10;
int num_y = 10;
int x_size = 400;
int y_size = 400;
int x_shift = 70;
int y_shift = 70;
int num_instances = 1;


AnimManager animator;

//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;

//we'll keep the cubes here
Cube[] cubes;
Pair[] pairs;


PFont titlefont;
PFont debugfont;

//For new Mac silicon chip to render 3D correctly:
import com.jogamp.opengl.GLProfile;
{
  GLProfile.initSingleton();
}

void setup() {
  //create OSC servers
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[hosts.length];
  for (int i = 0; i < hosts.length; i++) {
    server[i] = new NetAddress(hosts[i], 3334);
  }

  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i);
  }

  //create pairs
  pairs = new Pair[nPairs];
  pairsViz = new PairVisual[nPairs];
  if (zorozoro) {
    nPairs = zoropairs.length;
    for (int i = 0; i < nPairs; i++) {
      pairsViz[i] = new PairVisual();
      pairs[i] = new Pair(zoropairs[i][0], zoropairs[i][1]); // For Zorozoro
    }
  } else if (testMode) {
    xmin = 45;
    ymin = 45;
    xmax = 455;
    ymax = 455;
    
    xmid = (int) (xmax + xmin)/2;
    ymid = (int) (ymax + ymin)/2;
    
    for (int i = 0; i < nPairs; i++) {
      pairsViz[i] = new PairVisual();
      pairs[i] = new Pair(i + 12, i); //For Laptop-TOIO
    }
  } else {
    for (int i = 0; i < nPairs; i++) {
      pairsViz[i] = new PairVisual();
      pairs[i] = new Pair(i * 2, (i * 2) + 1); //For Laptop-TOIO
    }
  }

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  fullScreen(P3D);
  //size(1400, 1100, P3D);
  
  cam = new PeasyCam(this, 400);
  cam.setDistance(1600);
  cam.rotateX(-PI/2);

  //setup GUI
  setupGUI();

  smooth();
  blendMode(BLEND);

  titlefont = loadFont("Code-Light-80.vlw");
  debugfont = loadFont("Agenda-Light-48.vlw");
  frameRate(30);
  
  animator = new AnimManager();
  screensaver();
  animator.setViz();
  //animator.start();
}

void draw() {
  if (keyPressed && key == ' ') {
    cam.setActive(true);
  } else {
    cam.setActive(false);
  }
  
  if (animator.status == moveStatus.INPROGRESS) {
    animator.update();
  } 
 
  
  //if (guiOn) { 
  //    int[][][] targets;
  //    switch (guiChoose) {
  //      case CYLINDER:
  //        targets = animCylinderTwist();
  //        break;
        
  //      case LINE:
  //        targets = animRotateLine();
  //        break;
      
  //    //  case WAVE:
  //    //    targets = animWaveYCross();
  //    //    break; 
            
  //      default:
  //        targets = animTwoCylinder();
  //        break;
  //    }
      
  //    visualize(targets);
  //    //movePairsVelocity(targets);
  //}
  


  //START DO NOT EDIT
  drawDisplay();


  cam.beginHUD();


  textFont(titlefont, 60);

  fill(50, 50, 105);
  textAlign(LEFT, TOP);
  text("Threading Space \nController", 40, 40);
  
  //if (guiOn) {
  //fill(50, 50, 105);
  //textAlign(LEFT, TOP);
  //text("\n\nGUI", 40, 40);
  //}

  if (debugMode) {

    int debugUIx = width -350;
    int debugUIy = 50;
    textFont(debugfont, 24);
    textSize(24);
    fill(255, 0, 0);

    text("Playing Speed: " + playSpeed, debugUIx, debugUIy);
    textSize(20);
    text("Press UP/DOWN to tune", debugUIx+20, debugUIy+30);

    if (animator.size() > 0 && animator.getCurrentSeq() != null) {
      Sequence currSeq = animator.getCurrentSeq();
      if (animator.untangling) {
        text("Sequence " + (animator.iterator + 1) + "/" + animator.size() + ": UNTANGLING", debugUIx, 30 + debugUIy+60);
      } else {
        text("Sequence " + (animator.iterator + 1) + "/" + animator.size() + ": "+ currSeq.status, debugUIx, 30 + debugUIy+60);
      }
      if (currSeq instanceof DiscreteSequence) {
        DiscreteSequence discseq = (DiscreteSequence) currSeq;
        text("Frame " + (discseq.iterator + 1) + "/" + discseq.size() + ": "+ discseq.getCurrentFrame().status, debugUIx, 30 + debugUIy+90);
        textSize(24);
        for (int i  = 0; i < pairs.length; i++) {
          text("Toio " + i + ": "+ pairs[i].t.status + " " + pairs[i].b.status, debugUIx, 30 * i + debugUIy+150);
        }
      } else {
        SmoothSequence smoothseq = (SmoothSequence) currSeq;
        text("Second "+ (smoothseq.currTime / 1000) + "/" + round(smoothseq.timeLimit), debugUIx, 30 + debugUIy+90);
      }
    }
  }
  cp5.draw();
  cam.endHUD();
  //END DO NOT EDIT
}

  

public void controlEvent(ControlEvent theEvent) {
    println("got an event from"+theEvent.getController().getId());
    
   if (theEvent.isFrom(cp5.getController("LINEBUTTON"))) {
    println("this event was triggered by Controller n1");
    
  }
  
    //guiChoose = GUI.LINE;
    //setupGUI();
    
    switch (theEvent.getController().getId()) {
      case 0:
        mode = GUImode.SELECT;
        animator.setViz(false);
        setupGUI(); 
        break;
    }
    
    
  //  switch(theEvent.getController().getId()) {
  //  case(1):
  //  guiOn = !guiOn;
  //  setupGUI(); 
  //  animator.stop();
  //  //if (guiOn == false) {
  //  //  //stop();
  //  //  animator.start();
  //  //}
  //  break;
  //  case(2):
  //  if (guiOn == true) {
  //  guiChoose = GUI.LINE;
  //  setupGUI(); 
  //  break;
  //  }
  //  case(3):
  //  if (guiOn == true) {
  //  guiChoose = GUI.CYLINDER; 
  //  setupGUI(); 
  //  break;
  //  }
  //  //case(4):
  //  //if (guiOn == true) {
  //  //guiChoose = GUI.WAVE; 
  //  //setupGUI(); 
  //  //break;
  //  //}
  //  case(5): 
  //  if (guiOn ==false) {
  //   if (animator.status == moveStatus.NONE) {
  //    animator.start();
  //  } else {
  //    stop();
  //    animator.stop();
  //  }
  //  }
  //}
  
  }
