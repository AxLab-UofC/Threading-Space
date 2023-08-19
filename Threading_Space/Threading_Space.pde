import peasy.PeasyCam;
PeasyCam cam;


import oscP5.*;
import netP5.*;

//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection
int nCubes = 200;
int nPairs = 6;
int cubesPerHost = nCubes;
int maxMotorSpeed = 115;


//
boolean debugMode = false;


//Enable and Disable Zorozoro
boolean zorozoro = false;
int[][] zoropairs = {{185, 137}, {105, 171}, {118, 92}, {190, 145}, {127, 144}, {172, 148}};
int npairs = zoropairs.length;

//For Visualizing Posistions in GUI
boolean visualOn = true;
PairVisual[] pairsViz;

//for Threading Space Visualization
//int xmax = 949;
//int ymax = 898;
int vert = 500;

int xmax = 455;
int ymax = 455;


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
  //launch OSC sercer
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);

  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i);
  }

  pairs = new Pair[nPairs];
  pairsViz = new PairVisual[nPairs];
  if (zorozoro) {
    for (int i = 0; i < zoropairs.length; i++) {
      pairsViz[i] = new PairVisual();
      pairs[i] = new Pair(zoropairs[i][0], zoropairs[i][1]); // For Zorozoro
    }
  } else {
    for (int i = 0; i < nPairs; i++) {
      pairsViz[i] = new PairVisual();
      //pairs[i] = new Pair(i * 2, (i * 2) + 1); //For Laptop-TOIO
      pairs[i] = new Pair(i + 12, i); //For Laptop-TOIO
    }
  }

  //do not send TOO MANY PACKETS
  //we'll be updating the cubes every frame, so don't try to go too high
  fullScreen(P3D);
  cam = new PeasyCam(this, 400);
  cam.setDistance(1400);
  cam.rotateX(-PI/2);

  //setup GUI
  setupGUI();

  smooth();

  titlefont = loadFont("Code-Light-80.vlw");
  debugfont = loadFont("Agenda-Light-48.vlw");
  frameRate(30);
  
  animator = new AnimManager();
  DiscreteSequence seq = new DiscreteSequence();
  for (float step: smoothen(0, pairs.length, 29)) {
    //println(step);
    seq.addFrame(new Frame(moveType.BOTTOM, getCircle(step)));
  }
  seq.setSpeed(45);
  animator.add(seq);
}

void draw() {
  if (keyPressed && key == ' ') {
    cam.setActive(true);
  } else {
    cam.setActive(false);
  }
  
  if (animator.status != moveStatus.NONE) {
    animator.update();
  }
  

  animCylinder();
  


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


    text("Sequence " + (animator.iterator + 1) + "/" + animator.size() + ": "+ animator.getCurrentSeq().status, debugUIx, 30 + debugUIy+60);
    if (animator.getCurrentSeq() instanceof DiscreteSequence) {
      DiscreteSequence discseq = (DiscreteSequence) animator.getCurrentSeq();
      text("Frame " + (discseq.iterator + 1) + "/" + discseq.size() + ": "+ discseq.getCurrentFrame().status, debugUIx, 30 + debugUIy+90);
    }
    textSize(24);
    for (int i  = 0; i < pairs.length; i++) {
      text("Toio " + i + ": "+ pairs[i].t.status + " " + pairs[i].b.status, debugUIx, 30 * i + debugUIy+150);
    }
  }
  cp5.draw();
  cam.endHUD();
  //END DO NOT EDIT
}
