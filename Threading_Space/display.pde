//For Threading Space Style
color StringCol = color(0, 255, 255);
color backgroundCol = (180);
color ceilingCol = color(255, 255, 255);
color floorCol = color(255, 255, 255);
int stringWeight = 4;

int toioCylinderR = 12;
int toioCylinderH = 10;


void drawDisplay() {
  background (backgroundCol);
  noStroke();
  fill(200);
  rectMode(CENTER);
  background(255);


  long now = System.currentTimeMillis();

  //draw the "mats"
  background (backgroundCol);
  noStroke();
  fill(200);
  rectMode(CENTER);

  //draw floor
  pushMatrix();
  fill(floorCol);
  translate(0, 0, -vert);
  rect(0, 0, xmax, ymax);
  popMatrix();

  //draw ceiling
  pushMatrix();
  fill(ceilingCol);
  translate(0, 0, vert);
  rect(0, 0, xmax, ymax);
  popMatrix();


  for (int i = 0; i < nPairs; i++) {
    pairs[i].checkActive(now);
    boolean topActive = pairs[i].t.isActive;
    boolean bottomActive = pairs[i].b.isActive;

    pushMatrix();
    translate(-xmax/2, -ymax/2, 0);
    stroke(200);
    fill(255);
    strokeWeight(1);

    //Draw Top Toio
    pushMatrix();
    if (visualOn) {
      translate(pairsViz[i].t.x, pairsViz[i].t.y, vert - 5);


      drawVelocityLine(pairsViz[i].t.vx, pairsViz[i].t.vy);

      rotate(pairsViz[i].t.theta * PI/180);
      //box(12, 12, 7);
      drawCylinder(10, toioCylinderR, toioCylinderH);
    } else {
      if (topActive) {
        translate(pairs[i].t.x, ymax - pairs[i].t.y, vert - 5);

        drawVelocityLine(pairsViz[i].t.vx, pairsViz[i].t.vy);

        rotate(pairs[i].t.theta * PI/180);
        //box(12, 12, 7);
        drawCylinder(10, toioCylinderR, toioCylinderH);
      }
    }
    popMatrix();



    //Draw Bottom Toio
    pushMatrix();
    if (visualOn) {
      translate(pairsViz[i].b.x, pairsViz[i].b.y, -vert + 5);

      drawVelocityLine(pairsViz[i].b.vx, pairsViz[i].b.vy);

      rotate(pairsViz[i].b.theta * PI/180);
      //box(12, 12, 7);
      drawCylinder(10, toioCylinderR, toioCylinderH);
    } else {
      if (bottomActive) {
        translate(pairs[i].b.x, pairs[i].b.y, -vert + 5);

        drawVelocityLine(pairsViz[i].b.vx, pairsViz[i].b.vy);

        rotate(pairs[i].b.theta * PI/180);
        //box(12, 12, 7);
        drawCylinder(10, toioCylinderR, toioCylinderH);
      }
    }
    popMatrix();


    //Draw strings
    stroke(StringCol);
    strokeWeight(stringWeight);
    if (visualOn) {
      line(pairsViz[i].t.x, pairsViz[i].t.y, vert - toioCylinderH/2, pairsViz[i].b.x, pairsViz[i].b.y, -vert + toioCylinderH/2);
    } else {
      if (topActive && bottomActive) {
        line(pairs[i].t.x, ymax - pairs[i].t.y, vert - toioCylinderH/2, pairs[i].b.x, pairs[i].b.y, -vert+ toioCylinderH/2);
      }
    }

    popMatrix();
  }
}

//Function to draw Cylinder
void drawCylinder( int sides, float r, float h)
{

  float angle = 360 / sides;
  float halfHeight = h / 2;
  strokeWeight(2);
  stroke(200);
  // draw top of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);

  // draw bottom of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
  }
  endShape(CLOSE);

  // draw sides
  beginShape(TRIANGLE_STRIP);
  noStroke();
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);

  strokeWeight(2);
  stroke(255, 0, 0);
  // Red line to represent robot's theta
  line(0, 0, halfHeight, r, 0, halfHeight);
  line(0, 0, -halfHeight, r, 0, -halfHeight);
}


//

void drawVelocityLine(float vx, float vy) {

  if (debugMode) {
    //pushMatrix();
    float angle = atan2(vy, vx) + PI ;
    float scale = 1000; // scale the lenght of arrow

    float x_begin = cos(angle) * toioCylinderR;
    float y_begin = sin(angle) * toioCylinderR;

    stroke(0, 255, 0);
    strokeWeight(5);
    line(x_begin, y_begin, x_begin - vx*scale, y_begin - vy*scale);
  }
  //popMatrix();
}