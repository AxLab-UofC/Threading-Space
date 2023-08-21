boolean lineForwards = true;

float globalLineOffset = 0;
float globalLineOffsetSpeed;


void animLine(){
  
  elapsedTime = millis() - lastMillis;
  lastMillis = millis();
  
  globalLineOffset += (globalLineOffsetSpeed * elapsedTime);
  
  float lineOffset = (3 * xmax / 8) * sin(globalLineOffset / (100 * PI));
  
  int targets[][][] = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    targets[i][0][0] = (int) (((xmax + 45)/ 2) + (cos(i * PI) * lineOffset));
    targets[i][0][1] = (int) (ymax * (((.8 * i)/nPairs) + .1));
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (((xmax + 45)/ 2) + (cos(i * PI) * -lineOffset));
    targets[i][1][1] = (int) (ymax * (((.8 * i)/nPairs) + .1));
    targets[i][1][2] = 0;
  }
  
  visualize(targets);
}
