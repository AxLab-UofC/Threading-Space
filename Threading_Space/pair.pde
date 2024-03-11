class Pair {
  Cube t;
  Cube b;
  
  Pair(int top, int bottom) {
    t = cubes[top];
    cubes[top].onFloor = false;
    b = cubes[bottom];
  }
  
  void checkActive(long now) {
    t.checkActive(now);
    b.checkActive(now);
  }
  
  void motor(boolean leftforwards, int leftspeed, boolean rightforwards, int rightspeed) {
    t.motor(leftforwards, leftspeed, rightforwards, rightspeed);
    b.motor(leftforwards, leftspeed, rightforwards, rightspeed);
  }
  
  void target(int mode, int x, int y, int theta) {
    t.target(mode, x, y, theta);
    b.target(mode, x, y, theta);
  }
  
  void target(int control, int timeout, int mode, int maxspeed, int speedchange,  int x, int y, int theta) {
    t.target(control, timeout, mode, maxspeed, speedchange, x, y, theta);
    b.target(control, timeout, mode, maxspeed, speedchange, x, y, theta);
  }
  
  boolean velocityTarget(int x, int y) {
    return (t.velocityTarget(x, y) & b.velocityTarget(x, y));
  }
  
  void velocityTarget(int x, int y, float vx, float vy) {
    t.velocityTarget(x, y, vx, vy);
    b.velocityTarget(x, y, vx, vy);
  }
  
  void multiTarget(int mode, int[][] targets) {
    t.multiTarget(mode, targets);
    b.multiTarget(mode, targets);
  }
  
  void multiTarget(int control, int timeout, int mode, int maxspeed, int speedchange,  int[][] targets) {
    t.multiTarget(control, timeout, mode, maxspeed, speedchange, targets);
    b.multiTarget(control, timeout, mode, maxspeed, speedchange, targets);
  }
  
  void acceleration(int speed, int a, int rotateVelocity, int rotateDir, int dir, int priority, int duration) {
    t.acceleration(speed, a, rotateVelocity, rotateDir, dir, priority, duration);
    b.acceleration(speed, a, rotateVelocity, rotateDir, dir, priority, duration);
  }
}

//void moveTargets(int[][] spots) {
//   for (int i = 0; i < spots.length; i++) {
//    motorTarget(i, 0, spots[i][0], spots[i][1], spots[i][2]);
//  }
//}

//void moveTargets(float[][] spots) {
//   for (int i = 0; i < spots.length; i++) {
//    motorTarget(i, 0, int(spots[i][0]), int(spots[i][1]), int(spots[i][2]));
//  }
//}

//void multiMovePairs(int[][] spots) {
//   for(int i = 0;i < spots.length; i++) {
//    pairs[i].multiTarget(0, spots);
//  }
//}

void movePairs(int[][][] spots) {
  for(int i = 0;i < spots.length; i++) {
    pairs[i].t.target(0, spots[i][0][0], spots[i][0][1], spots[i][0][2]);
    pairs[i].b.target(0, spots[i][1][0], spots[i][1][1], spots[i][1][2]);
  }
}


void movePairs(int[][] spots) {
  for(int i = 0;i < spots.length; i++) {
    pairs[i].target(0, spots[i][0], spots[i][1], spots[i][2]);
  }
}


void movePairsVelocity(int[][][] targets, float[][][] velocity) {
  for (int i = 0; i < targets.length; i++) {
    pairs[i].t.velocityTarget(targets[i][0][0], targets[i][0][1], velocity[i][0][0], velocity[i][0][1]);
    pairs[i].b.velocityTarget(targets[i][1][0], targets[i][1][1], velocity[i][1][0], velocity[i][1][1]);
  }  
}

void movePairsVelocity(int[][][] targets) {
  for (int i = 0; i < targets.length; i++) {
    //pairs[i].t.velocityTarget(targets[i][0][0], targets[i][0][1]);
    //pairs[i].b.velocityTarget(targets[i][1][0], targets[i][1][1]);
    pairs[i].t.target(0, targets[i][0][0], targets[i][0][1], 0);
    pairs[i].b.target(0, targets[i][1][0], targets[i][1][1], 0);
  }  
}


//void movePairs(float[][] spots) {
//  for(int i = 0;i < spots.length; i++) {
//    pairs[i].target(0, int(spots[i][0]), int(spots[i][1]), int(spots[i][2]));
//  }
//}


//void moveTop(int[][] spots) {
//  for(int i = 0;i < spots.length; i++) {
//    pairs[i].t.target(0, spots[i][0], spots[i][1], spots[i][2]);
//  }
//}

//void moveTop(float[][] spots) {
//  for(int i = 0;i < spots.length; i++) {
//    pairs[i].t.target(0, int(spots[i][0]), int(spots[i][1]), int(spots[i][2]));
//  }
//}

//void moveBottom(int[][] spots) {
//  for(int i = 0;i < spots.length; i++) {
//    pairs[i].b.target(0, spots[i][0], spots[i][1], spots[i][2]);
//  }
//}

//void moveBottom(float[][] spots) {
//  for(int i = 0;i < spots.length; i++) {
//    pairs[i].b.target(0, int(spots[i][0]), int(spots[i][1]), int(spots[i][2]));
    
//  }
//}

void stopAll() {
   for (int i = 0; i < cubes.length; i++) {
    motorBasic(i, 0, 0);
  }
  animator.status = moveStatus.NONE;
}

int[][][] pairCheck() {
  float angle = (2 * PI) / nPairs;
  float radius = (xmax * 3) / 9;
  
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float theta = (i * angle);
    targets[i][0][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][0][1] = (int) (ymid - (radius * cos(theta)));
    targets[i][0][2] = (int) ((180 / PI) * (theta + PI/2));
    
    targets[i][1][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][1][1] = (int) (ymid + (radius * cos(theta)));
    targets[i][1][2] = (int) ((180 / PI) * (theta + PI/2));
  }
  
  return targets;
}

int[][][] translate(int[][] twod) {
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    targets[i][0] = twod[i];
    targets[i][1] = twod[i];
  }
  
  return targets;
}

void led(int id) {
  if (id == 10 || id == 11) {
    led(id, 0, 255, 0, 255);
  } else if (cubes[id].onFloor) {
    led(id, 0, 255, 0, 0);
  } else {
    led(id, 0, 0, 0, 255);
  }
}

void ledAll() {
  for (int i = 0; i < cubes.length; i++) {
    led(i);
  }
}

void ledOff() {
  for (int i = 0; i < cubes.length; i++) {
    led(i, 0, 0, 0, 0);
  }
}

void ledToggle() {
  if (ledOn) {
    ledOn = false;
    ledOff();
  } else {
    ledOn = true;
    ledAll();
  }
}

void swap(int id1, int id2) {
  boolean floor1 = (cubes[id1].onFloor);
  boolean floor2 = (cubes[id2].onFloor);
  
  for (int i = 0; i < nPairs; i++) {
    if (pairs[i].b.id == id1 || pairs[i].t.id == id1) {
      if (floor1) {
        pairs[i].b.id = id2;
      } else {
        pairs[i].t.id = id2;
      }
    }
  
    if (pairs[i].b.id == id2 || pairs[i].t.id == id2) {
      if (floor2) {
        pairs[i].b.id = id1;
      } else {
        pairs[i].t.id = id1;
      }
    }
  }
}
