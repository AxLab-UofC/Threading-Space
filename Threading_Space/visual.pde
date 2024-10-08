class CubeVisual {
  // position
  int x;
  int y;
  int theta;
  float vx;
  float vy;
  
  boolean onFloor;
  
  CubeVisual(boolean floor) {
    onFloor = floor;
  }
  
  void target(int upx, int upy, int uptheta) {
    x = upx;
    y = upy;
    theta = uptheta;
  }
  
  void target(int upx, int upy, int uptheta, float upvx, float upvy) {
    x = upx;
    y = upy;
    vx = upvx;
    vy = upvy;
    theta = uptheta;
  }
}

class PairVisual {
  CubeVisual t;
  CubeVisual b;
  
  PairVisual() {
    t = new CubeVisual(false);
    b = new CubeVisual(false);
  }
  
  void target(int upx, int upy, int uptheta) {
    t.target(upx, upy, uptheta);
    b.target(upx, upy, uptheta);
  }
}

void visualize(int[][] targets) {
  for (int i = 0; i < targets.length; i++) {
    pairsViz[i].target(targets[i][0], targets[i][1], targets[i][2]);
  }
}

void visualize(int[][][] targets) {
  for (int i = 0; i < targets.length; i++) {
    pairsViz[i].t.target(targets[i][0][0], targets[i][0][1], targets[i][0][2]);
    pairsViz[i].b.target(targets[i][1][0], targets[i][1][1], targets[i][1][2]);
  }
}

void visualizeVelocity(int[][][] targets, float [][][] velocity) {
  for (int i = 0; i < targets.length; i++) {
    pairsViz[i].t.target(targets[i][0][0], targets[i][0][1], targets[i][0][2], velocity[i][0][0], velocity[i][0][1]);
    pairsViz[i].b.target(targets[i][1][0], targets[i][1][1], targets[i][1][2], velocity[i][1][0], velocity[i][1][1]);
  }
}

void visualizeTop(int[][] targets) {
  for (int i = 0; i < targets.length; i++) {
    pairsViz[i].t.target(targets[i][0], targets[i][1], targets[i][2]);
  }
}

void visualizeBottom(int[][] targets) {
  for (int i = 0; i < targets.length; i++) {
    pairsViz[i].b.target(targets[i][0], targets[i][1], targets[i][0]);
  }
}
