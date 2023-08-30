enum GUI {
  CYLINDER, LINE
}

boolean globalLoading = true; 

enum GUImode {
  SCREENSAVER, SELECT, INTERACTIVE
}

GUI guiChoose = GUI.CYLINDER;
GUImode mode = GUImode.SCREENSAVER;

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
  

  switch (mode) {
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
     .setPosition(guiX,guiY+(2*guioffset))
     .setSize(200,50)
     .setId(2)
     ;
     
     cp5.addButton("CYLINDER")
     .setValue(100)
     .setPosition(guiX,guiY +(3*guioffset))
     .setSize(200,50)
     .setId(3)
     ;
     
     switch (guiChoose) {
       case CYLINDER: 
            cp5.addButton("GO")
             .setValue(100)
             .setPosition(guiX + 240,guiY +(3*guioffset))
             .setSize(200,50)
             .setId(6);
       break;
       
       case LINE: 
              cp5.addButton("GO")
             .setValue(100)
             .setPosition(guiX + 240,guiY +(2*guioffset))
             .setSize(200,50)
             .setId(7);
       break; 
     }
     break;
    
    case INTERACTIVE:
    
     cp5.addButton("LINE")
     .setValue(100)
     .setPosition(guiX,guiY+(2*guioffset))
     .setSize(200,50)
     .setId(4)
     ;
     
     cp5.addButton("CYLINDER")
     .setValue(100)
     .setPosition(guiX,guiY +(3*guioffset))
     .setSize(200,50)
     .setId(5)
     ;
     
     if (globalLoading == true) {
       switch (guiChoose) {
       case CYLINDER: 
            cp5.addButton("LOADING")
             .setValue(100)
             .setPosition(guiX + 240,guiY +(3*guioffset))
             .setSize(200,50)
             .setId(8);
       break;
       
       case LINE: 
              cp5.addButton("LOADING")
             .setValue(100)
             .setPosition(guiX + 240,guiY +(2*guioffset))
             .setSize(200,50)
             .setId(9);
       break; 
       }
     } else {
    
    switch (guiChoose) {
    case CYLINDER:
          cp5.addSlider("globalAngleOffsetSpeed")
          .setPosition(guiX+230, guiYadj+(3*guioffset))
          .setSize(200, 30)
          .setRange(-1, 1)
          .setValue(0)
          .setCaptionLabel("Total Speed")
          .setValue(globalAngleOffsetSpeed)
        ;
      
        cp5.addSlider("t_offsetAngleSpeed")
          .setPosition(guiX+230, guiYadj+(4*guioffset))
          .setSize(200, 30)
          .setRange(-1, 1)
          .setValue(0)
          .setCaptionLabel("Top Speed")
          .setValue(t_offsetAngleSpeed);
        ;
      
        cp5.addSlider("b_offsetAngleSpeed")
          .setPosition(guiX+230, guiYadj+(5*guioffset))
          .setSize(200, 30)
          .setRange(-1, 1)
          .setValue(0)
          .setCaptionLabel("Bottom Speed")
          .setValue(b_offsetAngleSpeed)
          ;
      
        cp5.addSlider("globalt_radius")
          .setPosition(guiX+230, guiYadj+(6*guioffset))
          .setSize(200, 30)
          .setRange(100, 300)
          .setValue(200)
          .setCaptionLabel("Top Radius")
          .setValue(globalt_radius)
          ;
          
         cp5.addSlider("globalb_radius")
          .setPosition(guiX+230, guiYadj+(7*guioffset))
          .setSize(200, 30)
          .setRange(100, 300)
          .setValue(200)
          .setCaptionLabel("Bottom Radius")
          .setValue(globalb_radius)
          ;
          break;
    
          
    //case WAVE: 
    //      cp5.addSlider("globalAmplitude")
    //      .setPosition(guiX+230, guiYadj+(3*guioffset))
    //      .setSize(200, 30)
    //      .setRange(100, 150)
    //      .setCaptionLabel("Amplitude")
    //      .setValue(globalAmplitude);
    //    break;
        
    case LINE:
          cp5.addSlider("globalAngleOffsetSpeed")
          .setPosition(guiX+230, guiYadj+(2*guioffset))
          .setSize(200, 30)
          .setRange(0, 1)
          .setValue(0.5)
          .setCaptionLabel("Speed")
          .setValue(globalAngleOffsetSpeed);
        break;
      
  }
     }
 
     
    break;
  }

  



  //   if (guiOn == true) {
     
  
  //  cp5.addButton("LINE")
  //   .setValue(100)
  //   .setPosition(guiX,guiY+(2*guioffset))
  //   .setSize(200,50)
  //   .setId(2)
  //   ;
     
  //   cp5.addButton("CYLINDER")
  //   .setValue(100)
  //   .setPosition(guiX,guiY +(3*guioffset))
  //   .setSize(200,50)
  //   .setId(3)
  //   ;
     
  //   //cp5.addButton("WAVE")
  //   //.setValue(100)
  //   //.setPosition(guiX,guiY+(3*guioffset))
  //   //.setSize(200,50)
  //   //.setId(4)
  //   //;
     
     
  //switch (guiChoose) {
  //  case CYLINDER:
  //        cp5.addSlider("globalAngleOffsetSpeed")
  //        .setPosition(guiX+230, guiYadj+(3*guioffset))
  //        .setSize(200, 30)
  //        .setRange(-1, 1)
  //        .setValue(0)
  //        .setCaptionLabel("Total Speed")
  //        .setValue(globalAngleOffsetSpeed)
  //      ;
      
  //      cp5.addSlider("t_offsetAngleSpeed")
  //        .setPosition(guiX+230, guiYadj+(4*guioffset))
  //        .setSize(200, 30)
  //        .setRange(-1, 1)
  //        .setValue(0)
  //        .setCaptionLabel("Top Speed")
  //        .setValue(t_offsetAngleSpeed);
  //      ;
      
  //      cp5.addSlider("b_offsetAngleSpeed")
  //        .setPosition(guiX+230, guiYadj+(5*guioffset))
  //        .setSize(200, 30)
  //        .setRange(-1, 1)
  //        .setValue(0)
  //        .setCaptionLabel("Bottom Speed")
  //        .setValue(b_offsetAngleSpeed)
  //        ;
      
  //      cp5.addSlider("globalt_radius")
  //        .setPosition(guiX+230, guiYadj+(6*guioffset))
  //        .setSize(200, 30)
  //        .setRange(100, 300)
  //        .setValue(200)
  //        .setCaptionLabel("Top Radius")
  //        .setValue(globalt_radius)
  //        ;
          
  //       cp5.addSlider("globalb_radius")
  //        .setPosition(guiX+230, guiYadj+(7*guioffset))
  //        .setSize(200, 30)
  //        .setRange(100, 300)
  //        .setValue(200)
  //        .setCaptionLabel("Bottom Radius")
  //        .setValue(globalb_radius)
  //        ;
  //        break;
          
  //  //case WAVE: 
  //  //      cp5.addSlider("globalAmplitude")
  //  //      .setPosition(guiX+230, guiYadj+(3*guioffset))
  //  //      .setSize(200, 30)
  //  //      .setRange(100, 150)
  //  //      .setCaptionLabel("Amplitude")
  //  //      .setValue(globalAmplitude);
  //  //    break;
        
  //  case LINE:
  //        cp5.addSlider("globalAngleOffsetSpeed")
  //        .setPosition(guiX+230, guiYadj+(2*guioffset))
  //        .setSize(200, 30)
  //        .setRange(0, 1)
  //        .setValue(0.5)
  //        .setCaptionLabel("Speed")
  //        .setValue(globalAngleOffsetSpeed);
  //      break;
      
  //}
     
  //   } else if (guiOn == false) {
       
       
  //   cp5.addButton("START/STOP ANIMATION")
  //   .setValue(100)
  //   .setPosition(guiX,(guiY))
  //   .setSize(200,50)
  //   .setId(5)
  //   ;
     
  //   }
     
  cp5.setAutoDraw(false);
}
