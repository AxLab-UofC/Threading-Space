float globalLineOffset;
float globalLineOffsetSpeed = 0.25;
float globalAmplitude;

int[][][] animLine(){
  
  elapsedTime = millis() - lastMillis;
  lastMillis = millis();
  
  globalLineOffset += (globalLineOffsetSpeed * elapsedTime);
  
  float lineOffset = (1 * xmax / 4) * sin(globalLineOffset / (100 * PI));
  
  int targets[][][] = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    int ystart = (ymin/2) + (int)((ymax - ymin) * (((.8 * i)/pairs.length) + .2));
    targets[i][0][0] = (int) (xmid + (cos(i * PI) * lineOffset));
    targets[i][0][1] = ystart;
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (xmid + (cos(i * PI) * -lineOffset));
    targets[i][1][1] = ystart;
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
    float r = (ymax * (((.8 * i)/nPairs) + .2)) - ymid;
    targets[i][0][0] = (int) (xmid + (r * sin(globalAngleOffset)));
    targets[i][0][1] = (int) (ymid + (r * cos(globalAngleOffset)));
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (xmid + (r * sin(globalAngleOffset)));
    targets[i][1][1] = (int) (ymid + (r * cos(globalAngleOffset)));
    targets[i][1][2] = 0;
  }
  
  return targets;
}


int[][] animWaveY() {
  int[][] targets = new int[nPairs][3];

  float time = millis() / 1000.0;
  float globalAmplitude = 120;  
  float frequency = 2;    
  
  int startY = ymid; // Centered along y-axis

  for (int i = 0; i < nPairs; i++) {
    int yOffset = (int) (globalAmplitude * cos(frequency * time + i * PI / nPairs));
    int startX = (xmin/2) + (int)((xmax - xmin) * (((.8 * i)/nPairs) + .2));
    
    targets[i][0] = startX;
    targets[i][1] = startY + yOffset;
    targets[i][2] = 0;
  }

  return targets;
}

int[][][] animWaveYCross() {
  int[][][] targets = new int[nPairs][2][3];

  float time = millis() / 1000.0;
  float globalAmplitude = 120;  
  float frequency = 2;    


  for (int i = 0; i < nPairs; i++) {
    float yOffset = globalAmplitude * cos(frequency * time + i * PI / nPairs);
    int yOffsetInt = int(yOffset);

    int startX = (xmin/2) + (int)((xmax - xmin) * (((.8 * i)/pairs.length) + .2));
    int startY = (ymax + ymin)/2; // Centered along y-axis

    targets[i][0][0] = startX;
    targets[i][0][1] = startY + yOffsetInt;
    targets[i][0][2] = pairs[i].t.theta;

    targets[i][1][0] = startX;
    targets[i][1][1] = ymax-(startY + yOffsetInt);
    targets[i][1][2] = pairs[i].b.theta;
  }

  return targets;
}
