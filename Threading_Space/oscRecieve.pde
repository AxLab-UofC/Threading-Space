int hostIndex(String host) {
  for (int i = 0; i < hosts.length; i++) {
    if (host.equals(hosts[i])) {
      return i;
    }
  }
  return -1;
}

void oscEvent(OscMessage msg) {
    try {
        int hostId = hostIndex(msg.address().substring(1));
        if (hostId == -1) {
            println("Invalid host: " + msg.address());
            return;
        }

        int id = (cubesPerHost * hostId) + msg.get(1).intValue();
        if (id < 0 || id >= cubes.length) {
            println("Invalid cube ID: " + id);
            return;
        }

        if (msg.checkAddrPattern("/position")) {
            if (msg.arguments().length < 5) {
                println("Incomplete /position message: " + msg);
                return;
            }
            int posx = msg.get(2).intValue();
            int posy = msg.get(3).intValue();
            int postheta = msg.get(4).intValue();
            cubes[id].positionUpdate(posx, posy, postheta);
        } 
        else if (msg.checkAddrPattern("/battery")) {
            if (msg.arguments().length < 3) {
                println("Incomplete /battery message: " + msg);
                return;
            }
            int battery = msg.get(2).intValue();
            cubes[id].batteryUpdate(battery);
        } 
        else if (msg.checkAddrPattern("/motion")) {
            if (msg.arguments().length < 7) {
                println("Incomplete /motion message: " + msg);
                return;
            }
            int flatness = msg.get(2).intValue();
            int hit = msg.get(3).intValue();
            int double_tap = msg.get(4).intValue();
            int face_up = msg.get(5).intValue();
            int shake_level = msg.get(6).intValue();
            cubes[id].motionUpdate(flatness, hit, double_tap, face_up, shake_level);
        } 
        else if (msg.checkAddrPattern("/magnetic")) {
            if (msg.arguments().length < 7) {
                println("Incomplete /magnetic message: " + msg);
                return;
            }
            int state = msg.get(2).intValue();
            int strength = msg.get(3).intValue();
            int forcex = msg.get(4).intValue();
            int forcey = msg.get(5).intValue();
            int forcez = msg.get(6).intValue();
            cubes[id].magneticUpdate(state, strength, forcex, forcey, forcez);
        } 
        else if (msg.checkAddrPattern("/postureeuler")) {
            if (msg.arguments().length < 5) {
                println("Incomplete /postureeuler message: " + msg);
                return;
            }
            int roll = msg.get(2).intValue();
            int pitch = msg.get(3).intValue();
            int yaw = msg.get(4).intValue();
            cubes[id].postureUpdate(roll, pitch, yaw);
        } 
        else if (msg.checkAddrPattern("/posturequaternion")) {
            if (msg.arguments().length < 6) {
                println("Incomplete /posturequaternion message: " + msg);
                return;
            }
            int w = msg.get(2).intValue();
            int x = msg.get(3).intValue();
            int y = msg.get(4).intValue();
            int z = msg.get(5).intValue();
            cubes[id].postureUpdate(w, x, y, z);
        } 
        else if (msg.checkAddrPattern("/button")) {
            if (msg.arguments().length < 3) {
                println("Incomplete /button message: " + msg);
                return;
            }
            int relid = msg.get(1).intValue();
            int pressValue = msg.get(2).intValue();
            if (pressValue == 0) {
                cubes[id].buttonUp();
            } else {
                cubes[id].buttonDown();
            }
        } 
        else if (msg.checkAddrPattern("/motorresponse")) {
            if (msg.arguments().length < 4) {
                println("Incomplete /motorresponse message: " + msg);
                return;
            }
            int control = msg.get(2).intValue();
            int response = msg.get(3).intValue();
            cubes[id].motorUpdate(control, response);
        } else {
            println("Unrecognized address pattern: " + msg.addrPattern());
        }
    } catch (Exception e) {
        println("Error processing OSC message: " + e.getMessage());
        e.printStackTrace();
    }
}
