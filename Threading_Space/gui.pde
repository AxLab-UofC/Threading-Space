enum animChoose {
  CYLINDER, LINE, CROSS
}

boolean globalLoading = true; 



int myLineColor = color(150,150,150);
int myCylinderColor = color(150,150,150);
int myCrossColor = color(150,150,150);

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
        .setId(0);
      break;
    
    case SELECT:
      cp5.addButton("LINE")
        .setValue(100)
        .setPosition(guiX,guiY+(3*guioffset))
        .setSize(200,50)
        .setColorBackground(myLineColor)
        .setColorActive(color(100,100,100))
        .setColorForeground(color(100,100,100))
        .setFont(buttonfont)
        .setId(1);
      
      cp5.addButton("CYLINDER")
        .setValue(100)
        .setPosition(guiX,guiY +(2*guioffset))
        .setSize(200,50)
        .setColorBackground(myCylinderColor)
        .setColorActive(color(100,100,100))
        .setColorForeground(color(100,100,100))
        .setFont(buttonfont)
        .setId(2);
        
       cp5.addButton("CROSS")
        .setValue(100)
        .setPosition(guiX,guiY +(4*guioffset))
        .setSize(200,50)
        .setColorBackground(myCrossColor)
        .setColorActive(color(100,100,100))
        .setColorForeground(color(100,100,100))
        .setFont(buttonfont)
        .setId(3);

       cp5.addButton("START")
       .setValue(100)
       .setPosition(guiX,guiY +(9*guioffset))
        .setSize(200,50)
       .setColorBackground(color(80,80,80))
       .setColorForeground(color(100,100,100))
       .setFont(buttonfont)
       .setId(6);

      break;
    
    case INTERACTIVE:
      cp5.addButton("LINE")
        .setValue(100)
        .setPosition(guiX,guiY+(3*guioffset))
        .setColorBackground(myLineColor)
        .setColorForeground(color(100,100,100))
        .setSize(200,50)
        .setFont(buttonfont)
        .setId(4);
      
      cp5.addButton("CYLINDER")
        .setValue(100)
        .setPosition(guiX,guiY +(2*guioffset))
        .setColorBackground(myCylinderColor)
        .setColorForeground(color(100,100,100))
        .setSize(200,50)
        .setFont(buttonfont)
        .setId(5);
        
       cp5.addButton("CROSS")
        .setValue(100)
        .setPosition(guiX,guiY +(4*guioffset))
        .setSize(200,50)
        .setColorBackground(myCrossColor)
        .setColorActive(color(100,100,100))
        .setColorForeground(color(100,100,100))
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
          
          case CROSS: 
           cp5.addSlider("globalLineOffset")
            .setPosition(guiX+230, guiYadj+(4*guioffset))
            .setSize(200, 30)
            .setRange(0, 100)
            .setValue(50)
            .setCaptionLabel("Speed")
            .setValue(globalLineOffset);
          break;
         

      }
     } else {
     
              cp5.addButton("LOADING")
              .setValue(100)
              .setPosition(guiX,guiY +(9*guioffset))
              .setSize(200,50)
              .setColorBackground(color(80,80,80))
              .setColorForeground(color(100,100,100))
              .setFont(buttonfont)
              .setId(9);

    }
    break;
  }
  cp5.setAutoDraw(false);
}
