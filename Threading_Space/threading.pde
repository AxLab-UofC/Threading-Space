int [][] getCircle(float offset) {
  int spots[][] = new int[nPairs][3];
  
  int r = 3 * min(xmax, ymax) / 8;
  float angle = 2 * PI/nPairs;
  
  for (int i = 0; i < nPairs; i++) {
    float newAngle = angle* ((i + offset) % nPairs);
    spots[i][0] = (int)(((xmax + 45)/ 2) + r*cos(newAngle));
    spots[i][1] = (int)(((ymax + 45) / 2) + r*sin(newAngle));
    spots[i][2] = (int)((360 * newAngle / (2 * PI)) + 90);
  }

  return spots;
}

int [][] getSpiral(float offset) {
  int spots[][] = new int[pairs.length][3];
  
  int r = 3 * min(xmax, ymax) / 8;
  float angle = 2 * PI/pairs.length;
  
  for (int i = 0; i < pairs.length; i++) {
    float newAngle = angle* ((i + offset) % pairs.length);
    spots[i][0] = (int)(((xmax + 45)/ 2) + (i * (float) r / pairs.length) * cos(newAngle));
    spots[i][1] = (int)(((ymax + 45) / 2) + (i * (float) r / pairs.length) * sin(newAngle));
    spots[i][2] = (int)((360 * newAngle / (2 * PI)) + 90);
  }

  return spots;
}


int[][] getLine(float offset) {
  int spots[][] = new int[pairs.length][3];
  
  for (int i = 0; i < pairs.length; i++) {
    spots[i][0] = (int) (((xmax + 45)/ 2) + (cos(i * PI) * offset));
    spots[i][1] = 23 + (int)((ymax - 45) * (((.8 * i)/pairs.length) + .2));
    spots[i][2] = 0;
  }
  
  return spots;
}

void ledAll() {
  for (int i = 0; i < cubes.length; i++) {
    if (!cubes[i].onFloor) {
      led(i, 0, 0, 0, 255);
    }
    else {
      led(i, 0, 255, 0, 0);
    }
  }
}
