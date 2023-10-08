void screensaver() {
  SmoothSequence seq;
  DiscreteSequence disc;
  
  seq = new SmoothSequence((float t) -> animJellyfish(t));
  seq.setPeriod(5);
  seq.setTimeLimit(10);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animCircle(t));
  seq.setPeriod(10);
  seq.setTimeLimit(10);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animCircleTwist(t));
  seq.setPeriod(10);
  seq.setTimeLimit(15);
  seq.setTangle(true);
  animator.add(seq);
  
  //disc = new DiscreteSequence();
  //for (int i = 0; i <= nPairs; i++) {
  //   disc.addFrame(new Frame(moveType.PAIR, animCircle(i/nPairs)));
  //}
  //animator.add(disc);
  
  animator.add(new PathPlanSequence(animRotateLine(0)));
  
  seq = new SmoothSequence((float t) -> animRotateLine(t));
  seq.setPeriod(16);
  seq.setTimeLimit(28);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animRotateLineTwist(t));
  seq.setPeriod(20);
  seq.setTimeLimit(10);
  seq.setTangle(true);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animRotateLine(t));
  seq.setPeriod(16);
  seq.setTimeLimit(8);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animLine(t));
  seq.setPeriod(8);
  seq.setTimeLimit(16);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animRotateLine(t + .5));
  seq.setPeriod(16);
  seq.setTimeLimit(4);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animWave(t));
  seq.setTimeLimit(20);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animRotateLine(t + .75));
  seq.setPeriod(16);
  seq.setTimeLimit(4);
  animator.add(seq);
  
  animator.add(new PathPlanSequence(animCircle(0)));
  
  seq = new SmoothSequence((float t) -> animCircle(t));
  seq.setPeriod(15);
  seq.setTimeLimit(15);
  animator.add(seq);
  
  seq = new SmoothSequence((float t) -> animFastTwist(t));
  seq.setPeriod(15);
  seq.setTimeLimit(15);
  seq.setTangle(true);
  animator.add(seq);
  
  
  animator.setLoop();
}

int[][]   animCircle(float t) {
  float angleOffset = t * (2 * PI);
  float angle = (2 * PI) / nPairs;
  float radius = (max * 3) / 9;
  
  int[][] targets = new int[nPairs][3];
  
  for (int i = 0; i < nPairs; i++) {
    float theta = (i * angle) + angleOffset;
    targets[i][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][1] = (int) (ymid + (radius * cos(theta)));
    targets[i][2] = (int) ((180 / PI) * (theta + PI/2));
  }
  
  return targets;
}

int[][][] animCircleTwist(float t) {
  float angleOffset = t * (2 *PI);
  float angle = (2 * PI) / nPairs;
  float radius = (max * 3) / 9;
  
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float theta = (i * angle);
    targets[i][0][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][0][1] = (int) (ymid + (radius * cos(theta)));
    targets[i][0][2] = (int) ((180 / PI) * (theta + PI/2));
    
    theta = (i * angle) + (angleOffset);
    targets[i][1][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][1][1] = (int) (ymid + (radius * cos(theta)));
    targets[i][1][2] = (int) ((180 / PI) * (theta + PI/2));
  }
  
  return targets;
}

int[][][] animFastTwist(float t) {
  float angleOffset = t * (2 *PI);
  float angle = (2 * PI) / nPairs;
  float radius = (max * 3) / 9;
  
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float theta = (i * angle) + angleOffset;
    targets[i][0][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][0][1] = (int) (ymid + (radius * cos(theta)));
    targets[i][0][2] = (int) ((180 / PI) * (theta + PI/2));
    
    theta = (i * angle) - angleOffset;
    targets[i][1][0] = (int) (xmid + (radius * sin(theta)));
    targets[i][1][1] = (int) (ymid + (radius * cos(theta)));
    targets[i][1][2] = (int) ((180 / PI) * (theta + PI/2));
  }
  
  return targets;
}

int[][][] animJellyfish(float t) {
  float angleOffset = t * (2 *PI);
  float angle = (2 * PI) / nPairs;
  float upperRadius = max * (((float)2/9) + (sin(angleOffset)/9));
  float lowerRadius = max * (((float)2/9) + (cos(angleOffset)/9));
  
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float theta = (i * angle);
    targets[i][0][0] = (int) (xmid + (upperRadius * sin(theta)));
    targets[i][0][1] = (int) (ymid + (upperRadius * cos(theta)));
    targets[i][0][2] = (int) ((180 / PI) * (theta + PI/2));
    
    targets[i][1][0] = (int) (xmid + (lowerRadius * sin(theta)));
    targets[i][1][1] = (int) (ymid + (lowerRadius * cos(theta)));
    targets[i][1][2] = (int) ((180 / PI) * (theta + PI/2));
  }
  
  return targets;
}

int[][][] animLine(float t) {
  float angleOffset = t * (2 * PI) + (PI/2);
  float amplitude = (max * 2 /9);
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    int ystart = (ymin/2) + (int)((ymax - ymin) * (((.8 * i)/pairs.length) + .2));
    targets[i][0][0] = (int) (xmid + (cos((i * PI) + angleOffset) * amplitude));
    targets[i][0][1] = ystart;
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (xmid + (cos((i * PI) + angleOffset) * - amplitude));
    targets[i][1][1] = ystart;
    targets[i][1][2] = 0;
  }
  
  return targets;
}

int[][]   animRotateLine(float t) {
  float angleOffset = t * (2 * PI);
  
  int[][] targets = new int[nPairs][3];
  
  for (int i = 0; i < nPairs; i++) {
    float r = (ymax * (((.8 * (nPairs - i - 1))/nPairs) + .2)) - ymid;
    targets[i][0] = (int) (xmid + (r * sin(angleOffset)));
    targets[i][1] = (int) (ymid + (r * cos(angleOffset)));
    targets[i][2] = 0;
    
  }
  
  return targets;
}

int[][][] animRotateLineTwist(float t) {
  float angleOffset = t * (2 * PI);
  
  int[][][] targets = new int[nPairs][2][3];
  
  for (int i = 0; i < nPairs; i++) {
    float r = (ymax * (((.8 * (nPairs - i - 1))/nPairs) + .2)) - ymid;
    targets[i][0][0] = (int) (xmid + (r * sin(angleOffset)));
    targets[i][0][1] = (int) (ymid + (r * cos(angleOffset)));
    targets[i][0][2] = 0;
    
    
    targets[i][1][0] = (int) (xmid + (r * sin(-angleOffset)));
    targets[i][1][1] = (int) (ymid + (r * cos(-angleOffset)));
    targets[i][1][2] = 0;
    
  }
  
  return targets;
}

int[][]   animWave(float t) {
  float amplitude = (xmax * 2)/ 9;  
  float frequency = 5;    
  int startY = (ymax + ymin)/2; // Centered along y-axis
  
  amplitude *= min(1, t * 4);
  
  int[][] targets = new int[nPairs][3];
  
  for (int i = 0; i < nPairs; i++) {
    int startX = (xmin/2) + (int)((xmax - xmin) * (((.8 * i)/nPairs) + .2));
    int yOffset = (int) (amplitude * cos(frequency * t + i * PI / nPairs));
    
    targets[i][0] = startX;
    targets[i][1] = startY + yOffset;
    targets[i][2] = 0;
  }
  
  return targets;
}
