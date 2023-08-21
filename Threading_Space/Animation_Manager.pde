enum moveType {
  TOP, BOTTOM, PAIR, INDEPENDENT
}

class AnimManager {
  moveStatus status = moveStatus.NONE;
  ArrayList<Sequence> sequences;
  int iterator;
 
  AnimManager() {
    sequences = new ArrayList<Sequence>();
    iterator = 0;
  }
  
  void add(Frame newFrame) {
    sequences.add(new DiscreteSequence(newFrame));
  }
  
  void add(Sequence newSeq) {
    sequences.add(newSeq);
  }
  
  void start() {
    if (sequences.size() > 0) {
      sequences.get(iterator).start();
    }
    status = moveStatus.INPROGRESS;
  }
  
  void stop() {
    status = moveStatus.NONE;
  }
  
  void update() {
    if (sequences.size() > 0) {
      boolean seqComplete = sequences.get(iterator).update();
      if (seqComplete) {
        if (iterator + 1 == sequences.size()) {
          status = moveStatus.COMPLETE;
        } else {
          iterator++;
          sequences.get(iterator).start();
        }
      } 
    }
  }
  
  Sequence getCurrentSeq() {
    if (size() > 0) {
      return sequences.get(iterator);
    }
    
    return null;
  }
  
  int size() {
    return sequences.size();
  }
}

class Sequence {
  moveStatus status = moveStatus.NONE;
  
  void start() {
    status = moveStatus.INPROGRESS;
  }
  
  void stop() {
    status = moveStatus.NONE;
  }
  
  boolean update(){
    return false;
  }
}

interface Movement  {
  int[][] get(int time);
}

interface IndependentMovement {
  int[][][] get(int time);
}



class SmoothSequence extends Sequence {
  moveStatus status = moveStatus.NONE;
  moveType type;
  Movement func;
  int startTime;
  int timeOffset = 0;
  IndependentMovement indieFunc;
  int[][] targets;
  int[][] indieTargets;
  
  SmoothSequence(IndependentMovement newFunc) {
    type = moveType.INDEPENDENT;
    indieFunc = newFunc;
  }
  
  SmoothSequence(moveType tpe, Movement newFunc) {
    type = tpe;
    func = newFunc;
  }
  
  void start() {
    startTime = millis() - timeOffset;
    status = moveStatus.INPROGRESS;
  }
  
  void stop() {
    timeOffset = millis() - startTime;
    status = moveStatus.NONE;
  }
  
  boolean update() {
    int currTime = millis() - startTime;
    switch (type) {
      case TOP:
        targets = func.get(currTime / 1000);
        for (int i = 0; i < targets.length; i++) {
          pairs[i].t.target(0, 5, 0, 50, 0, targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      case BOTTOM:
        targets = func.get(currTime / 1000);
        for (int i = 0; i < targets.length; i++) {
          pairs[i].b.target(0, 5, 0, 50, 0, targets[i][0], targets[i][1], targets[i][2]);
        }
      break;
      case PAIR:
        targets = func.get(currTime / 1000);
        for (int i = 0; i < targets.length; i++) {
          pairs[i].target(0, 5, 0, 50, 0, targets[i][0], targets[i][1], targets[i][2]);
        }
      break;
      case INDEPENDENT:
      break;
    }
    return false;
  }
}


class DiscreteSequence extends Sequence {
  moveStatus status = moveStatus.NONE;
  int speed = 80;
  ArrayList<Frame> frames;
  int iterator;
  
  DiscreteSequence(){
    frames = new ArrayList<Frame>();
    iterator = 0;
  }
  
  DiscreteSequence(Frame first){
    frames = new ArrayList<Frame>();
    frames.add(first);
    iterator = 0;
  }
  
  DiscreteSequence(Frame[] firstFrames){
    frames = new ArrayList<Frame>();
    for (int i = 0; i < firstFrames.length; i++) {
      frames.add(firstFrames[i]);
    }
    iterator = 0;
  }
  
  void addFrame(Frame newFrame) {
    if (speed != 80) {
      newFrame.setSpeed(speed);
    }
    frames.add(newFrame);
  }
  
  void setSpeed(int newSpeed) {
    speed = newSpeed;
    for (Frame frame: frames) {
      frame.setSpeed(newSpeed);
    }
  }
  
  void start() {
    frames.get(iterator).execute();
    status = moveStatus.INPROGRESS;
  }
  
  boolean update(){
    boolean frameComplete = frames.get(iterator).update();
      if (frameComplete) {
        if (iterator + 1 == frames.size()) {
          status = moveStatus.COMPLETE;
          return true;
        } else {
          iterator++;
          frames.get(iterator).execute();
        }
      } 
      return false;
  }
  
  Frame getCurrentFrame() {
    return frames.get(iterator);
  }
  
  int size() {
    return frames.size();
  }
}

class Frame {
  moveStatus status = moveStatus.NONE;
  moveType type;
  int speed = 80;
  int[][] targets;
  int[][][] indieTargets;
  
  Frame(moveType tpe, int[][] spots) {
    type = tpe;
    targets = spots;
  }
  
  Frame(int[][][] spots) {
    type = moveType.INDEPENDENT;
    indieTargets = spots;
  }
  
  void setSpeed(int newSpeed) {
    speed = newSpeed;
  }
  
  void execute() {
    status = moveStatus.INPROGRESS;
    switch(type) {
      case PAIR:
        for (int i = 0; i < targets.length; i++) {
          pairs[i].target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      
      case TOP:
        for (int i = 0; i < targets.length; i++) {
          pairs[i].t.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      
      case BOTTOM:
        for (int i = 0; i < targets.length; i++) {
          pairs[i].b.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      
      case INDEPENDENT:
        for (int i = 0; i < indieTargets.length; i++) {
          pairs[i].t.target(0, 5, 0, speed, 0, indieTargets[i][0][0], indieTargets[i][0][1], indieTargets[i][0][2]);
          pairs[i].b.target(0, 5, 0, speed, 0, indieTargets[i][1][0], indieTargets[i][1][1], indieTargets[i][1][2]);
        }
        break;
    }
  }
  
  boolean update() {
    moveStatus tempStatus = moveStatus.COMPLETE;
    for (int i = 0; i < pairs.length; i++) {
      switch (type) {
        case PAIR:
          if (pairs[i].t.status == moveStatus.INPROGRESS || pairs[i].b.status == moveStatus.INPROGRESS)  {
            tempStatus = moveStatus.INPROGRESS;
          } 
          
          if (pairs[i].t.status == moveStatus.ERROR) {
            tempStatus = moveStatus.INPROGRESS;
            motorDuration(pairs[i].t.id, 255, 5);
            pairs[i].t.status = moveStatus.NONE;
          } else if (pairs[i].t.status == moveStatus.NONE) {
            tempStatus = moveStatus.INPROGRESS;
            pairs[i].t.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          }
          
          if (pairs[i].b.status == moveStatus.ERROR) {
            tempStatus = moveStatus.INPROGRESS;
            motorDuration(pairs[i].b.id, 255, 5);
            pairs[i].b.status = moveStatus.NONE;
          } else if (pairs[i].b.status == moveStatus.NONE) {
            tempStatus = moveStatus.INPROGRESS;
            pairs[i].b.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          }
          break;
          
        case TOP:
          if (pairs[i].t.status == moveStatus.INPROGRESS) {
            tempStatus = moveStatus.INPROGRESS;
          } else if (pairs[i].t.status == moveStatus.ERROR) {
            tempStatus = moveStatus.INPROGRESS;
            motorDuration(pairs[i].t.id, 255, 5);
            pairs[i].t.status = moveStatus.NONE;
          } else if (pairs[i].t.status == moveStatus.NONE) {
            tempStatus = moveStatus.INPROGRESS;
            pairs[i].t.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          }
          break;
        case BOTTOM:
          if (pairs[i].b.status == moveStatus.INPROGRESS) {
            tempStatus = moveStatus.INPROGRESS;
          } else if (pairs[i].b.status == moveStatus.ERROR) {
            tempStatus = moveStatus.INPROGRESS;
            motorDuration(pairs[i].b.id, 255, 5);
            pairs[i].b.status = moveStatus.NONE;
          } else if (pairs[i].b.status == moveStatus.NONE) {
            tempStatus = moveStatus.INPROGRESS;
            pairs[i].b.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          }
          break;
        case INDEPENDENT:
          if (pairs[i].t.status == moveStatus.INPROGRESS || pairs[i].b.status == moveStatus.INPROGRESS)  {
            tempStatus = moveStatus.INPROGRESS;
          } 
          
          if (pairs[i].t.status == moveStatus.ERROR) {
            tempStatus = moveStatus.INPROGRESS;
            motorDuration(pairs[i].t.id, 255, 5);
            pairs[i].t.status = moveStatus.NONE;
          } else if (pairs[i].t.status == moveStatus.NONE) {
            tempStatus = moveStatus.INPROGRESS;
            pairs[i].t.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          }
          
          if (pairs[i].b.status == moveStatus.ERROR) {
            tempStatus = moveStatus.INPROGRESS;
            motorDuration(pairs[i].b.id, 255, 5);
            pairs[i].b.status = moveStatus.NONE;
          } else if (pairs[i].b.status == moveStatus.NONE) {
            tempStatus = moveStatus.INPROGRESS;
            pairs[i].b.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          }
          break;
      }
    }
    status = tempStatus;
    return (status == moveStatus.COMPLETE);
  }
}
