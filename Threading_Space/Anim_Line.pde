float globalLineOffset;
float globalLineOffsetSpeed = 0.5;


int[][][] animLine(){
  
  elapsedTime = millis() - lastMillis;
  lastMillis = millis();
  
  globalLineOffset += (globalLineOffsetSpeed * elapsedTime);
  
  float lineOffset = (3 * xmax / 8) * sin(globalLineOffset / (100 * PI));
  
  int targets[][][] = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    targets[i][0][0] = (int) (((xmax + 45)/ 2) + (cos(i * PI) * lineOffset));
    targets[i][0][1] = (int) (ymax * (((.8 * i)/nPairs) + .2));
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (((xmax + 45)/ 2) + (cos(i * PI) * -lineOffset));
    targets[i][1][1] = (int) (ymax * (((.8 * i)/nPairs) + .2));
    targets[i][1][2] = 0;
  }
  
  
  return targets;
}

int[][][] animRotateLine(){
  
  elapsedTime = millis() - lastMillis;
  lastMillis = millis();

  float timeScale = playSpeed * float(elapsedTime)/1000;

  // Update the parameter based on speed //
  globalAngleOffset += (globalAngleOffsetSpeed * timeScale);

  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float r = (ymax * (((.8 * i)/nPairs) + .2)) - (ymax/2);
    targets[i][0][0] = (int) ((xmax + 45)/2 + (r * sin(globalAngleOffset)));
    targets[i][0][1] = (int) ((ymax + 45)/2 + (r * cos(globalAngleOffset)));
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) ((xmax + 45)/2 + (r * sin(globalAngleOffset)));
    targets[i][1][1] = (int) ((ymax + 45)/2 + (r * cos(globalAngleOffset)));
    targets[i][1][2] = 0;
  }
  
  return targets;
}


int[][][] animWave() {
  int[][][] targets = new int[nPairs][2][3];

  float time = millis() / 1000.0;
  float amplitude = 80;  
  float frequency = 2;    

  float initialXOffset = xmax / (nPairs + 1); // Equally spread out along x-axis

  for (int i = 0; i < nPairs; i++) {
    float yOffset = amplitude * cos(frequency * time + i * PI / nPairs);
    int yOffsetInt = int(yOffset);

    int startX = int((i + 1) * initialXOffset);
    int startY = (ymax + 45) / 2; // Centered along y-axis

    targets[i][0][0] = startX;
    targets[i][0][1] = startY + yOffsetInt;
    targets[i][0][2] = pairs[i].t.theta;

    targets[i][1][0] = startX;
    targets[i][1][1] = startY + yOffsetInt;
    targets[i][1][2] = pairs[i].b.theta;
  }

  return targets;
}
