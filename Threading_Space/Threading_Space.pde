import peasy.PeasyCam;  //<>//
PeasyCam cam;
import deadpixel.command.*;

import oscP5.*;
import netP5.*;

import java.util.*;

//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection

int nPairs = 5;
int nCubes = 12;
int cubesPerHost = 12;
int maxMotorSpeed = 115;

int lastpressed;
boolean globalLoading; 

//server ids
String[] hosts = {"127.0.0.1","169.254.249.26"};


//For testing on small mat
boolean testMode = false;


//Enable and Disable Zorozoro
boolean zorozoro = false;
int[][] zoropairs = {{185, 137}, {105, 171}, {118, 92}, {190, 145}, {127, 144}, {172, 148}};

//For Visualizing Posistions and Debug mode in GUI
boolean debugMode = false;
boolean visualOn = true;
boolean ledOn = false;
PairVisual[] pairsViz;

//for Threading Space Visualization
int xmin = 34;
int ymin = 35;
int xmax = 644; //949;
int ymax = 466; //898;
int max = min(ymax,xmax);
float xyScale = 1;
int vert = 500;


int xmid = (int) (xmax + xmin)/2;
int ymid = (int) (ymax + ymin)/2;

//For Path Planning

int num_x = 15;
int num_y = 15;
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
PFont buttonfont;

color dark = color(100,100,100);
color light = color(150,150,150); 
color toggle_ = color(150,150,150);

boolean debugtoggle = false; 

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

    num_x = 10;
    num_y = 10;
    x_size = 450;
    y_size = 450;

    max = min(ymax,xmax);
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

  titlefont = loadFont("Code-Light-80.vlw");
  debugfont = loadFont("Agenda-Light-48.vlw");
  buttonfont = loadFont("SukhumvitSet-Thin-20.vlw");
  frameRate(30);
  
  //setup GUI
  resetVariables();
  setupGUI();

  smooth();
  blendMode(BLEND);

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
        text("Frame " + (discseq.iterator + 1) + "/" + discseq.size() + ": "+ discseq.status, debugUIx, debugUIy+150);
        textSize(24);
        for (int i  = 0; i < pairs.length; i++) {
          text("Toio " + i + ": "+ pairs[i].t.status + " " + pairs[i].b.status, debugUIx, 30 * i + debugUIy+180);
        }
      } else if (currSeq instanceof SmoothSequence) {
        SmoothSequence smoothseq = (SmoothSequence) currSeq;
        text("Second "+ (smoothseq.currTime / 1000) + "/" + round(smoothseq.timeLimit), debugUIx, debugUIy+150);
      }
    }
  }
      
  cp5.draw();
  cam.endHUD();
  //END DO NOT EDIT
  if ((millis() - lastpressed) > 20000000) {
    guiState = GUImode.SCREENSAVER;
    setupGUI();
  }
}



public void controlEvent(ControlEvent theEvent) {
  switch (theEvent.getController().getId()) {
    case 0:
      guiState = GUImode.SELECT;
      animator.setViz(false);
      setupGUI();
      break;

    case 1:
      guiChoose = animChoose.LINE;
      myLineColor = dark;
      myCylinderColor = light;
      myWaveColor = light;
      setupGUI();
      break;

    case 2:
      guiChoose = animChoose.CYLINDER;
      myLineColor = light;
      myCylinderColor = dark;
      myWaveColor = light;
      setupGUI();
      break;

    case 3:
     guiChoose = animChoose.WAVE;      
     myLineColor = light;
      myCylinderColor = light;
      myWaveColor = dark;
      setupGUI();
      break;

    case 4:
      if (guiChoose != animChoose.LINE) {
        guiState = GUImode.SELECT;
        guiChoose = animChoose.LINE;
        myLineColor = dark;
        myCylinderColor = light;
        myWaveColor = light;
        setupGUI();
      } 
      lastpressed = millis();
      break;

    case 5:
      if (guiChoose != animChoose.CYLINDER) {
        guiState = GUImode.SELECT;
        guiChoose = animChoose.CYLINDER;
        myLineColor = light;
        myCylinderColor = dark;
        myWaveColor = light;
        setupGUI();
      }
      lastpressed = millis();
      break;

    case 6:
      if (guiChoose == animChoose.CYLINDER) {
        myLineColor = light;
        myCylinderColor = dark;
        myWaveColor = light;
      } else if (guiChoose == animChoose.LINE) {
        myLineColor = dark;
        myCylinderColor = light;
        myWaveColor = light;
      } else {
        myLineColor = light;
        myCylinderColor = light;
        myWaveColor = dark;
      }
      realChoose = guiChoose;
      globalLoading = true; 
      setupGUI(); //<>// //<>//
      animator.startInteractive(); //<>//
      setupGUI(); 
      lastpressed = millis();

      break;

      case 7:
       if (guiChoose != animChoose.WAVE) {
       guiState = GUImode.SELECT;
        guiChoose = animChoose.WAVE;    
        myLineColor = light;
        myCylinderColor = light;
        myWaveColor = dark;
        setupGUI();
      }
      lastpressed = millis();
      break;
      
      case 10:
      ledToggle(); 
      if (ledOn) {
        toggle_ = color(100,100,100);
      } else {
        toggle_ = color(150,150,150); 
      }
      setupGUI(); 
      break;
      
      case 11: 
      //led(int); 
      //println("controlEvent: accessing a string from controller '"+theEvent.getName()+"': "+theEvent.getStringValue());
      break; 
      
      case 12:

      break;
      
      case 13:
      //swap 2
      break; 
     
      
  }
}

class CircularButton implements ControllerView<Button> {

  public void display(PGraphics theApplet, Button theButton) {
    theApplet.pushMatrix();
    //theApplet.setValueColor(color(0,0,0));
    theApplet.strokeWeight(3);
    if (theButton.isInside()) {
      if (theButton.isPressed()) { // button is pressed
        theApplet.stroke(color(0, 0, 0, 100));
      }  else { // mouse hovers the button
        theApplet.stroke(color(0, 0,0, 100));
      }
    } else { // the mouse is located outside the button area
      theApplet.stroke(color(50,50,50, 100));
    }
    
    theApplet.ellipse(0, 0, theButton.getWidth(), theButton.getHeight());
    
    // center the caption label 
    int x = 40;
    int y = 10;
    
    translate(x, y);
     theButton.getCaptionLabel().setColor(color(0,0,0));
    theButton.getCaptionLabel().draw(theApplet);
    theApplet.popMatrix();
  }
}

    public void Enter1(){   
      String tempAns = cp5.get(Textfield.class,"LED").getText();
      println("led"+tempAns);
      led(Integer.parseInt(tempAns)); 
    } 
    
    public void Enter2() {
      String tempAns1 = cp5.get(Textfield.class,"swap1").getText();
      String tempAns2 = cp5.get(Textfield.class,"swap2").getText();  
      println("swap"+tempAns1+ " "+ tempAns2);
      swap(Integer.parseInt(tempAns1),Integer.parseInt(tempAns2)); 
    } 
    
