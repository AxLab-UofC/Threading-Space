int[][] lineGen() {
  int xmid = (cubes[10].x + cubes[11].x) / 2;
  int ymid = (cubes[10].y + cubes[11].y) / 2;
  
  int[][] targets = new int[nPairs][2];
  
  if (cubes[10].y - cubes[11].y != 0) {
    float s = (float) (cubes[10].x - cubes[11].x) / (float) (cubes[10].y - cubes[11].y);
    int[] limits = lineLimits(ymid, xmid, s);
  
      for (int i = 0; i < nPairs; i++) {
        int circx = (int) lerp(limits[0], limits[1], (float) i / (nPairs - 1));
        
        targets[i][0] = circx;
        targets[i][1] = lineGet(ymid, xmid, s, circx);
      }
  } else {
    
      for (int i = 0; i < nPairs; i++) {
        
        targets[i][0] = xmin + (i * 50);
        targets[i][1] = ymid;
      }
    
  }
  
  return targets;
}

int[] lineLimits(int ymid, int xmid, float s) {
  int lefty = ymid - int(s * (xmin - xmid));
  int righty = ymid - int(s * (xmax - xmid));
  
  int buffer = 50;
  
  int newymax = ymax - buffer;
  int newymin = ymin + buffer;
  
  int leftx;
  if (lefty > newymax) {
    leftx = int(xmid + ((ymid - newymax) / s));
  } else if (lefty < newymin) {
    leftx = int(xmid + ((ymid - newymin) / s));
  } else {
    leftx = xmin + buffer;
  }
  
  int rightx;
  if (righty > newymax) {
    rightx = int(xmid + ((ymid - newymax) / s));
  } else if (righty < newymin) {
    rightx = int(xmid + ((ymid - newymin) / s));
  } else {
    rightx = xmax - buffer;
  }
  
  //int[] ret = {min(leftx, rightx), max(leftx, rightx)};
  int[] ret = {leftx, rightx};
  return ret;
}

int lineGet(int ymid, int xmid, float s, int x) {
  return ymid - int(s * (x - xmid));
}
