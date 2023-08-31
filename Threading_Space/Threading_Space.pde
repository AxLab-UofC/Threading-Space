import peasy.PeasyCam;
PeasyCam cam;
import deadpixel.command.*;


import oscP5.*;
import netP5.*;

import java.util.*;

//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection
int nCubes = 20;
int nPairs = 6;
int cubesPerHost = 20;
int maxMotorSpeed = 115;

int lastpressed; 

//server ids
String[] hosts = {"127.0.0.1","169.254.0.2"};


//For testing on small mat
boolean testMode = true;


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
int num_x = 33;
int num_y = 33;
int x_size = 990;
int y_size = 990;
int x_shift = xmin + 20;
int y_shift = ymin + 20;
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
    //xmin = 45;
    //ymin = 45;
    //xmax = 455;
    //ymax = 455;
    
    xmid = (int) (xmax + xmin)/2;
    ymid = (int) (ymax + ymin)/2;
    
    for (int i = 0; i < nPairs; i++) {
      pairsViz[i] = new PairVisual();
      pairs[i] = new Pair(i + nPairs, i); //For Laptop-TOIO
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
 
  
  if (mode == GUImode.SELECT || mode == GUImode.INTERACTIVE) { 
      int[][][] targets;
      switch (guiChoose) {
        case CYLINDER:
          targets = animCylinderTwist();
          break;
        
        case LINE:
          targets = animRotateLine();
          break;

        default:
          targets = animTwoCylinder();
          break;
      }
      
      visualize(targets);
      if (animator.interactive) movePairsVelocity(targets);
  }
  


  //START DO NOT EDIT
  drawDisplay();


  cam.beginHUD();


  textFont(titlefont, 60);

  fill(50, 50, 105);
  textAlign(LEFT, TOP);
  text("Threading Space \nController", 40, 40);
  

  if (debugMode) {

    int debugUIx = width -350;
    int debugUIy = 50;
    textFont(debugfont, 24);
    textSize(24);
    fill(255, 0, 0);

    text("Playing Speed: " + playSpeed, debugUIx, debugUIy);
    textSize(20);
    text("Press UP/DOWN to tune", debugUIx+20, debugUIy+30);

    text("STATUS: " + animator.getStatus(), debugUIx, debugUIy+90);
    if (animator.size() > 0 && animator.getCurrentSeq() != null) {
      Sequence currSeq = animator.getCurrentSeq();
      if (animator.untangling) {
        text("Sequence " + (animator.iterator + 1) + "/" + animator.size() + ": UNTANGLING", debugUIx, debugUIy+120);
      } else {
        text("Sequence " + (animator.iterator + 1) + "/" + animator.size() + ": "+ currSeq.status, debugUIx, debugUIy+120);
      }
      if (currSeq instanceof DiscreteSequence) {
        DiscreteSequence discseq = (DiscreteSequence) currSeq;
        text("Frame " + (discseq.iterator + 1) + "/" + discseq.size() + ": "+ discseq.getCurrentFrame().status, debugUIx, debugUIy+150);
        textSize(24);
        for (int i  = 0; i < pairs.length; i++) {
          text("Toio " + i + ": "+ pairs[i].t.status + " " + pairs[i].b.status, debugUIx, 30 * i + debugUIy+180);
        }
      } else {
        SmoothSequence smoothseq = (SmoothSequence) currSeq;
        text("Second "+ (smoothseq.currTime / 1000) + "/" + round(smoothseq.timeLimit), debugUIx, debugUIy+150);
      }
    }
  }
  cp5.draw();
  cam.endHUD();
  //END DO NOT EDIT
  if ((millis() - lastpressed) > 20000000) {
    mode = GUImode.SCREENSAVER;
    setupGUI();
  }
}

  

public void controlEvent(ControlEvent theEvent) { 
  switch (theEvent.getController().getId()) {
    case 0:
      mode = GUImode.SELECT;
      animator.setViz(false);
      setupGUI(); 
      break;

    case 2:
      guiChoose = GUI.LINE;
      resetFunction();
      setupGUI(); 
      break;

    case 3:
      guiChoose = GUI.CYLINDER;
      resetFunction();
      setupGUI(); 
      break;

    case 4: 
      if (guiChoose != GUI.LINE) {
        mode = GUImode.SELECT; 
        guiChoose = GUI.LINE;
        globalLoading = true;
        setupGUI(); 
      }
      lastpressed = millis(); 
      break; 

    case 5: 
      if (guiChoose != GUI.CYLINDER) {
        mode = GUImode.SELECT; 
        guiChoose = GUI.CYLINDER;
        globalLoading = true;
        setupGUI(); 
      }
      lastpressed = millis();
      break;

    case 6: 
      globalLoading = true;
      mode = GUImode.INTERACTIVE;
      setupGUI();
      animator.startInteractive();
      lastpressed = millis();
      break;

    case 7: 
      globalLoading = true;
      mode = GUImode.INTERACTIVE;
      setupGUI();
      animator.startInteractive();
      lastpressed = millis();
      break;

    //case 8: 
    //  globalLoading = false;
    //  resetFunction();
    //  setupGUI(); 
    //  lastpressed = millis();
    //  break;

    //case 9: 
    //  globalLoading = false;
    //  resetFunction();
    //  lastpressed = millis();
    //  setupGUI(); 
    //  break;
  }
}
