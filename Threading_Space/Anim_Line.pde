float globalLineOffset;
float globalLineOffsetSpeed = 0.25;


int[][][] animLine(float t) {
  float angleOffset = t * (2 * PI) + (PI/2);
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    int ystart = (ymin/2) + (int)((ymax - ymin) * (((.8 * i)/pairs.length) + .2));
    targets[i][0][0] = (int) (xmid + (cos((i * PI) + angleOffset) * (xmax * 3 /8)));
    targets[i][0][1] = ystart;
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (xmid + (cos((i * PI) + angleOffset) * - (xmax * 3 /8)));
    targets[i][1][1] = ystart;
    targets[i][1][2] = 0;
  }
  
  return targets;
}

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

int[][][] animRotateLine(float t) {
  float angleOffset = t * (2 * PI);
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float r = (ymax * (((.8 * (nPairs - i - 1))/nPairs) + .2)) - ymid;
    targets[i][0][0] = (int) (xmid + (r * sin(angleOffset)));
    targets[i][0][1] = (int) (ymid + (r * cos(angleOffset)));
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (xmid + (r * sin(angleOffset)));
    targets[i][1][1] = (int) (ymid + (r * cos(angleOffset)));
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


int[][][] animWaveY() {
  int[][][] targets = new int[nPairs][2][3];

  float time = millis() / 1000.0;
  float amplitude = 120;  
  float frequency = 2;    


  for (int i = 0; i < nPairs; i++) {
    float yOffset = amplitude * cos(frequency * time + i * PI / nPairs);
    int yOffsetInt = int(yOffset);

    int startX = (xmin/2) + (int)((xmax - xmin) * (((.8 * i)/pairs.length) + .2));
    int startY = (ymax + ymin)/2; // Centered along y-axis

    targets[i][0][0] = startX;
    targets[i][0][1] = startY + yOffsetInt;
    targets[i][0][2] = pairs[i].t.theta;

    targets[i][1][0] = startX;
    targets[i][1][1] = startY + yOffsetInt;
    targets[i][1][2] = pairs[i].b.theta;
  }

  return targets;
}

int[][][] animWaveYCross() {
  int[][][] targets = new int[nPairs][2][3];

  float time = millis() / 1000.0;
  float amplitude = 120;  
  float frequency = 2;    


  for (int i = 0; i < nPairs; i++) {
    float yOffset = amplitude * cos(frequency * time + i * PI / nPairs);
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