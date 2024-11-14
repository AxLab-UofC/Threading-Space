boolean motorTargetVelocity(int id, int x, int y, float vx, float vy) {
  if (!cubes[id].onFloor) {
    x = xmax - x + xmin;
    vx = -vx;
  }

  if (cubes[id].isActive) {
    int left = 0;
    int right = 0;
    float angleToTarget = atan2(y - cubes[id].y, x - cubes[id].x);

    float thisAngle = cubes[id].theta * PI / 180;
    float diffAngle = thisAngle - angleToTarget;
    if (diffAngle > PI) diffAngle -= TWO_PI;
    if (diffAngle < -PI) diffAngle += TWO_PI;

    // Add a small dead zone to prevent jitter
    if (abs(diffAngle) < 0.1) diffAngle = 0;

    if (abs(diffAngle) > HALF_PI) {
      float frac = cos(diffAngle);
      if (diffAngle > 0) {
        left = floor(maxMotorSpeed * pow(frac, 2));
        right = maxMotorSpeed;
      } else {
        left = maxMotorSpeed;
        right = floor(maxMotorSpeed * pow(frac, 2));
      }
    } else {
      float frac = -cos(diffAngle);
      if (diffAngle > 0) {
        left = -floor(maxMotorSpeed * pow(frac, 2));
        right = -maxMotorSpeed;
      } else {
        left = -maxMotorSpeed;
        right = -floor(maxMotorSpeed * pow(frac, 2));
      }
    }
    int[] lr = {left, right};

    float velIntegrate = sqrt(sq(vx) + sq(vy));
    float aimMotSpeed = velIntegrate / 2.0; // variable that decide how much velocity mapping affect the final motor speed (2.0)
    float aa = (lr[0] < 0) ? -aimMotSpeed : aimMotSpeed;

    float dd = cubes[id].distance(x, y) / 100; //slow down proportionally based on the distance from the target (100)
    dd = min(dd, 1);

    float targetLeft = constrain(aa + (lr[0] * dd), -maxMotorSpeed, maxMotorSpeed);
    float targetRight = constrain(aa + (lr[1] * dd), -maxMotorSpeed, maxMotorSpeed);

    // Apply smoothing to motor speeds
    float left_ = 0;
    float right_ = 0;
    float smoothFactor = 0;
    left_ = smoothFactor * left_ + (1 - smoothFactor) * targetLeft;
    right_ = smoothFactor * right_ + (1 - smoothFactor) * targetRight;

    // Update motor with smoothed values
    int duration = 100;
    motorDuration(id, (int)left_, (int)right_, duration);
  }
  return false;
}
