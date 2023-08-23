float overallTimeMillis = 5 * 60 * 1000; // 5 mins
float playSpeed = 1;

float globalAngleOffset=0;
float globalAngleOffsetSpeed = 0.5; //0.05;

float t_offsetAngle = 0;
float t_offsetAngleSpeed = 0.5; //=-0.05;

float b_offsetAngle = 0;
float b_offsetAngleSpeed =  0; //-0.05;

float globalInnerAngleOffset=0;
float globalInnerAngleOffsetSpeed = 0.2; //0.05;

float t_radius = 300;
float t_radiusSpeed = 0.7;

float b_radius = 330;
float b_radiusSpeed = -2;

float t_inner_radius = 100;
float t_outer_radius = 300;
float b_inner_radius = 100;
float b_outer_radius = 300; 

int lastMillis = 0;

int lastSpots [][][] = new int[nPairs][2][3];
float velocity [][][] = new float[nPairs][2][2]; 


int elapsedTime;

int[][][] animCylinder(float t, float speed, float offset) {
  int[][][] targets = new int[nPairs][2][3];
  
  float angle = 2 * PI/(nPairs);
  
  for (int i = 0; i < nPairs; i++) {
    float newAngle = (angle * i) + globalAngleOffset;
    targets[i][0][0] = int((xmax + xmin)/2 + t_radius*cos(newAngle)); //x
    targets[i][0][1] = int((ymax + ymin)/2 + t_radius*sin(newAngle)); //y
    targets[i][0][2] = int((360 * (newAngle + t_offsetAngle) / (2 * PI)) + 90); //theta

    targets[i][1][0] = int((xmax + xmin)/2 + b_radius*cos(newAngle + b_offsetAngle)); //x
    targets[i][1][1]= int((ymax + ymin)/2 + b_radius*sin(newAngle + b_offsetAngle)); //y
    targets[i][1][2] = int((360 * (newAngle + b_offsetAngle) / (2 * PI)) + 90); //theta
  }
  
  return targets;
  
}

int[][][] animCylinder() {

  elapsedTime = millis() - lastMillis;
  lastMillis = millis();

  float timeScale = playSpeed * float(elapsedTime)/1000;

  // Update the parameter based on speed //
  globalAngleOffset += globalAngleOffsetSpeed * timeScale;
  
  t_radius = (xmax * 3/9);
  b_radius = (xmax * 3/9);
  
  int[][][] targets = new int[nPairs][2][3];
  
  float angle = 2 * PI/(nPairs);
  
  for (int i = 0; i < nPairs; i++) {
    float newAngle = (angle * i) + globalAngleOffset;
    targets[i][0][0] = int((xmax + xmin)/2 + t_radius*cos(newAngle)); //x
    targets[i][0][1] = int((ymax + ymin)/2 + t_radius*sin(newAngle)); //y
    targets[i][0][2] = int((360 * (newAngle) / (2 * PI)) + 90); //theta

    targets[i][1][0] = int((xmax + xmin)/2 + b_radius*cos(newAngle)); //x
    targets[i][1][1]= int((ymax + ymin)/2 + b_radius*sin(newAngle)); //y
    targets[i][1][2] = int((360 * (newAngle) / (2 * PI)) + 90); //theta
  }
  
  return targets;
}

int[][][] animCylinderTwist() {

  elapsedTime = millis() - lastMillis;
  lastMillis = millis();

  float timeScale = playSpeed * float(elapsedTime)/1000;

  // Update the parameter based on speed //
  globalAngleOffset += globalAngleOffsetSpeed * timeScale;


  t_radius += t_radiusSpeed * timeScale;
  b_radius += b_radiusSpeed * timeScale;
  

  t_offsetAngle += t_offsetAngleSpeed * timeScale;
  b_offsetAngle += b_offsetAngleSpeed * timeScale;



  // Flip the speed when reaching to min/max//
  if (t_radius > 450) {
    t_radiusSpeed = -abs(t_radiusSpeed);
  } else if (t_radius<100) {
    t_radiusSpeed = abs(t_radiusSpeed);
  }

  if (b_radius > 450) {
    b_radiusSpeed = -abs(b_radiusSpeed);
  } else if (b_radius < 100) {
    b_radiusSpeed = abs(b_radiusSpeed);
  }

  if (t_offsetAngle > radians(360)) {
    t_offsetAngleSpeed = -abs(t_offsetAngleSpeed);
  } else if (b_offsetAngle < radians(-360)) {
    t_offsetAngleSpeed = abs(t_offsetAngleSpeed);
  }
  if (b_offsetAngle > radians(360)) {
    b_offsetAngleSpeed = -abs(b_offsetAngleSpeed);
  } else if (b_offsetAngle < radians(-360)) {
    b_offsetAngleSpeed = abs(b_offsetAngleSpeed);
  }
  
  int[][][] targets = new int[nPairs][2][3];
  
  float angle = 2 * PI/(nPairs);
  
  for (int i = 0; i < nPairs; i++) {
    float newAngle = (angle * i) + globalAngleOffset;
    targets[i][0][0] = int((xmax + xmin)/2 + t_radius*cos(newAngle + t_offsetAngle)); //x
    targets[i][0][1] = int((ymax + ymin)/2 + t_radius*sin(newAngle + t_offsetAngle)); //y
    targets[i][0][2] = int((360 * (newAngle + t_offsetAngle) / (2 * PI)) + 90); //theta

    targets[i][1][0] = int((xmax + xmin)/2 + b_radius*cos(newAngle + b_offsetAngle)); //x
    targets[i][1][1]= int((ymax + ymin)/2 + b_radius*sin(newAngle + b_offsetAngle)); //y
    targets[i][1][2] = int((360 * (newAngle + b_offsetAngle) / (2 * PI)) + 90); //theta
  }
  
  return targets;
}


int[][][] animTwoCylinder() {

  elapsedTime = millis() - lastMillis;
  lastMillis = millis();

  float timeScale = playSpeed * float(elapsedTime)/1000;

  // Update the parameter based on speed //
  globalAngleOffset += globalAngleOffsetSpeed * timeScale;
  globalInnerAngleOffset += globalInnerAngleOffsetSpeed * timeScale;
  
  float outer_radius = (xmax * 3/9);
  float inner_radius = (xmax * 2/9);
  
  int[][][] targets = new int[nPairs][2][3];
  
  float angle = 2 * PI/(nPairs);
  
  for (int i = 0; i < nPairs; i++) {
    float r = outer_radius;
    float newAngle = (angle * i) + globalAngleOffset;
    
    if (i % 2 == 1) {
      r = inner_radius;
      newAngle = (angle * i) + globalAngleOffset + globalAngleOffset;
    }
    
    targets[i][0][0] = int((xmax + xmin)/2 + r*cos(newAngle)); //x
    targets[i][0][1] = int((ymax + ymin)/2 + r*sin(newAngle)); //y
    targets[i][0][2] = int((360 * (newAngle) / (2 * PI)) + 90); //theta

    targets[i][1][0] = int((xmax + xmin)/2 + r*cos(newAngle)); //x
    targets[i][1][1]= int((ymax + ymin)/2 + r*sin(newAngle)); //y
    targets[i][1][2] = int((360 * (newAngle) / (2 * PI)) + 90); //theta
  }
  
  return targets;
}
