float overallTimeMillis = 5 * 60 * 1000; // 5 mins
float playSpeed = 1;

float globalAngleOffset=0;
float globalAngleOffsetSpeed = 0.1; //0.05;

float t_offsetAngle = 0;
float t_offsetAngleSpeed = 0.05; //=-0.05;

float b_offsetAngle = 0;
float b_offsetAngleSpeed =  0; //-0.05;


float t_radius = 300;
float t_radiusSpeed = 0.7;

float b_radius = 330;
float b_radiusSpeed = -2;

int lastMillis = 0;

int lastSpots [][][] = new int[nPairs][2][3];
float velocity [][][] = new float[nPairs][2][2]; 


int elapsedTime;

void animCylinder() {

  elapsedTime = millis() - lastMillis;
  lastMillis = millis();

  // visualize
  
  visualizeVelocity(getCylinderTwist(xmax/2, ymax/2, t_radius, b_radius, globalAngleOffset, t_offsetAngle, b_offsetAngle), velocity);
  movePairsVelocity(getCylinderTwist(xmax/2, ymax/2, t_radius, b_radius, globalAngleOffset, t_offsetAngle, b_offsetAngle), velocity);

  // save last spot to calculate velocity.
  lastSpots = getCylinderTwist(xmax/2, ymax/2, t_radius, b_radius, globalAngleOffset, t_offsetAngle, b_offsetAngle);

  float timeScale = playSpeed * float(elapsedTime)/1000;



  // Update the parameter based on speed //
  globalAngleOffset += globalAngleOffsetSpeed * timeScale;


  //t_radius += t_radiusSpeed * timeScale;
  //b_radius += b_radiusSpeed * timeScale;
  
  t_radius = (xmax * 3/9);
  b_radius = (xmax * 3/9);

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
}


int [][][] getCylinderTwist(int x, int y, float topR, float bottomR, float globalAngle, float topOffsetAngle, float bottomOffsetAngle) {
  float angle = 2 * PI/(nPairs);
  int spots[][][] = new int[nPairs][2][3]; //[num of pairs] [top or bottom] [x, y, theta, vx, vy]


  for (int i = 0; i < nPairs; i++) {
    float newAngle = angle*i  +globalAngle;
    spots[i][0][0] = int(x + topR*cos(newAngle + topOffsetAngle)); //x
    spots[i][0][1] = int(y + topR*sin(newAngle + topOffsetAngle)); //y
    spots[i][0][2] = int((360 * (newAngle + topOffsetAngle) / (2 * PI)) + 90); //theta

    spots[i][1][0] = int(x + bottomR*cos(newAngle + bottomOffsetAngle)); //x
    spots[i][1][1]= int(y + bottomR*sin(newAngle + bottomOffsetAngle)); //y
    spots[i][1][2] = int((360 * (newAngle + bottomOffsetAngle) / (2 * PI)) + 90); //theta
  }

  if (lastSpots != null) {
    
    // calculate Velocity
    for (int i = 0; i < nPairs; i++) {
      velocity[i][0][0] = float(lastSpots[i][0][0] - spots[i][0][0] )/  float(elapsedTime); // x
      velocity[i][0][1] = float(lastSpots[i][0][1] - spots[i][0][1] )/  float(elapsedTime); // y
            
      
      velocity[i][1][0] = float(lastSpots[i][1][0] - spots[i][1][0] )/  float(elapsedTime); // x
      velocity[i][1][1] = float(lastSpots[i][1][1] - spots[i][1][1] )/  float(elapsedTime); // y
    }
    
    
  }

  return spots;
}
