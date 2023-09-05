enum animChoose {
  CYLINDER, LINE, WAVE
}

Textfield LED; 

int myLineColor = color(150,150,150);
int myCylinderColor = color(150,150,150);
int myWaveColor = color(150,150,150);

enum GUImode {
  SCREENSAVER, SELECT, INTERACTIVE
}

animChoose guiChoose = animChoose.CYLINDER;
animChoose realChoose = animChoose.CYLINDER;
GUImode guiState = GUImode.SCREENSAVER;

import controlP5.*;
ControlP5 cp5;

Accordion accordion;

int twistV = 0;
float tepardR_c = 0;
float tepardR_f = 0;

float lineGap = 0;
float spacing = 0;
int xPos = 0;

Slider2D s;

int guiX = 40;
int guiY = 200;
int guiYadj = 213;
int guioffset = 60; 


void setupGUI() {

  cp5 = new ControlP5(this);
         


  switch (guiState) {
    case SCREENSAVER:
      cp5.addButton("EXPLORE")
        .setValue(100)
        .setPosition(width/2 - 100,height * 9/10)
        .setSize(200,50)
        .setFont(buttonfont)
        .setColorBackground(color(100,100,100))
        .setColorActive(dark)
        .setColorForeground(dark)
        .setId(0);
      break;
    
    case SELECT:
      cp5.addButton("LINE")
        .setValue(100)
        .setPosition(guiX,guiY+(3*guioffset))
        .setSize(200,50)
        .setColorBackground(myLineColor)
        .setColorActive(dark)
        .setColorForeground(dark)
        .setFont(buttonfont)
        .setId(1);
      
      cp5.addButton("CYLINDER")
        .setValue(100)
        .setPosition(guiX,guiY +(2*guioffset))
        .setSize(200,50)
        .setColorBackground(myCylinderColor)
        .setColorActive(dark)
        .setColorForeground(dark)
        .setFont(buttonfont)
        .setId(2);
        
       cp5.addButton("WAVE")
        .setValue(100)
        .setPosition(guiX,guiY +(4*guioffset))
        .setSize(200,50)
        .setColorBackground(myWaveColor)
        .setColorActive(dark)
        .setColorForeground(dark)
        .setFont(buttonfont)
        .setId(3);

    if (animator.animState == animatorMode.TOINTERACTIVE){
      cp5.addButton("LOADING")
        .setValue(100)
        .setPosition(guiX + 25,guiY +(5.5*guioffset))
        .setSize(150,40)
        .setColorBackground(color(80,80,80))
        .setColorForeground(color(100,100,100))
        .setFont(buttonfont)
        .setView(new CircularButton())
        .setId(9);
    } else {
       cp5.addButton("CHOOSE")
       .setValue(100)
       .setPosition(guiX + 25,guiY +(5.5*guioffset))
        .setSize(150,40)
       .setColorBackground(color(0,150,150))
       .setColorForeground(color(0,180,180))
       .setFont(buttonfont)
       .setView(new CircularButton())
       .setId(6);
    }
      break;
    
    case INTERACTIVE:
   
      cp5.addButton("LINE")
        .setValue(100)
        .setPosition(guiX,guiY+(3*guioffset))
        .setColorBackground(myLineColor)
        .setColorForeground(dark)
        .setSize(200,50)
        .setFont(buttonfont)
        .setId(4);
      
      cp5.addButton("CYLINDER")
        .setValue(100)
        .setPosition(guiX,guiY +(2*guioffset))
        .setColorBackground(myCylinderColor)
        .setColorForeground(dark)
        .setSize(200,50)
        .setFont(buttonfont)
        .setId(5);
        
       cp5.addButton("WAVE")
        .setValue(100)
        .setPosition(guiX,guiY +(4*guioffset))
        .setSize(200,50)
        .setColorBackground(myWaveColor)
        .setColorActive(dark)
        .setColorForeground(dark)
        .setFont(buttonfont)
        .setId(7);
        
        
     if (animator.animState == animatorMode.INTERACTIVE) {
       switch (realChoose) {
        case CYLINDER:
          cp5.addSlider("globalAngleOffsetSpeed")
            .setPosition(guiX+230, guiYadj+(2*guioffset))
            .setSize(200, 30)
            .setRange(-1, 1)
            .setValue(0)
            .setCaptionLabel("Total Speed")
            .setValue(globalAngleOffsetSpeed);
        
          cp5.addSlider("t_offsetAngleSpeed")
            .setPosition(guiX+230, guiYadj+(3*guioffset))
            .setSize(200, 30)
            .setRange(-1, 1)
            .setValue(0)
            .setCaptionLabel("Top Speed")
            .setValue(t_offsetAngleSpeed);
        
          cp5.addSlider("b_offsetAngleSpeed")
            .setPosition(guiX+230, guiYadj+(4*guioffset))
            .setSize(200, 30)
            .setRange(-1, 1)
            .setValue(0)
            .setCaptionLabel("Bottom Speed")
            .setValue(b_offsetAngleSpeed);
        
          cp5.addSlider("globalt_radius")
            .setPosition(guiX+230, guiYadj+(5*guioffset))
            .setSize(200, 30)
            .setRange(100, 300)
            .setValue(200)
            .setCaptionLabel("Top Radius")
            .setValue(globalt_radius);
            
          cp5.addSlider("globalb_radius")
            .setPosition(guiX+230, guiYadj+(6*guioffset))
            .setSize(200, 30)
            .setRange(100, 300)
            .setValue(200)
            .setCaptionLabel("Bottom Radius")
            .setValue(globalb_radius);
          break;
        
        case LINE:
          cp5.addSlider("globalAngleOffsetSpeed")
            .setPosition(guiX+230, guiYadj+(3*guioffset))
            .setSize(200, 30)
            .setRange(0, 1)
            .setValue(0.5)
            .setCaptionLabel("Speed")
            .setValue(globalAngleOffsetSpeed);
          break;
          
          case WAVE: 
           cp5.addSlider("globalLineOffset")
            .setPosition(guiX+230, guiYadj+(4*guioffset))
            .setSize(200, 30)
            .setRange(0, 100)
            .setValue(50)
            .setCaptionLabel("Speed")
            .setValue(globalLineOffset);
          break;
      }
     }
    
    break;
  }
  
  if (debugMode) {
   
    
        cp5.addButton("LED ON/OFF")
        .setValue(100)
        .setPosition(width - 300,guiY +(5*guioffset))
        .setSize(200,50)
        .setColorBackground(toggle_)
        .setColorForeground(toggle_)
        .setFont(buttonfont)
        .setId(10); 
        
        LED = cp5.addTextfield("LED")
          .setPosition(width - 290,guiY +(6.5*guioffset))
         .setSize(80, 40)
         .setFont(buttonfont)
         .setColor(light)
         .setAutoClear(true)
         .setId(11);
          
          cp5.addBang("Enter1")
          .setPosition(width - 190,guiY +(6.5*guioffset))
          .setSize(80, 40)
          .setColorForeground(dark)
          .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
             
             
           cp5.addTextfield("swap1")
            .setPosition(width - 390,guiY +(8*guioffset))
           .setSize(80, 40)
           .setFont(buttonfont)
           .setColorValue(color(255,255,255))
           .setColor(light)
           .setAutoClear(true)
           .setId(12);
         
           cp5.addTextfield("swap2")
          .setPosition(width - 290,guiY +(8*guioffset))
         .setSize(80, 40)
         .setFont(buttonfont)
         .setColor(light)
         .setAutoClear(true)
         .setId(13);
         
           cp5.addBang("Enter2")
          .setPosition(width - 190,guiY +(8*guioffset))
          .setSize(80, 40)
          .setColorForeground(dark)
          .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
             
              
  }
    
  cp5.setAutoDraw(false);
}
