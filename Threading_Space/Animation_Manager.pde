enum moveType {
  TOP, BOTTOM, PAIR, INDEPENDENT
}

enum animatorMode {
  SCREENSAVER, INTERACTIVE, TOSCREENSAVER, TOINTERACTIVE
}

class AnimManager {
  moveStatus status = moveStatus.NONE;
  ArrayList<Sequence> sequences;
  Sequence currSeq;
  int iterator;
  boolean loop = false;
  boolean viz = false;
  boolean untangling = false;
  
  animatorMode animState = animatorMode.SCREENSAVER;
  
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
  
  void setLoop(boolean val) {
    loop = val;
  }
  
  void setLoop() {
    loop = !loop;
  }
  
  void setViz(boolean newViz) {
    viz = newViz;
    for (Sequence seq: sequences) {
      seq.setViz(viz);
    }
  }
  
  void setViz() {
    viz = !viz;
    for (Sequence seq: sequences) {
      seq.setViz(viz);
    }
  }
  
  void start() {
    if (animState == animatorMode.INTERACTIVE) {
      lastMillis = millis();
    } else if (sequences.size() > 0) {
      if (currSeq == null) {
        currSeq = sequences.get(0);
      }
      currSeq.start();
    }
    status = moveStatus.INPROGRESS;
  }
  
  void startInteractive() {
    if (currSeq != null) {
      untangleClear();
    }
    
    stop();
    resetVariables();
    switch (realChoose) {
      case CYLINDER:
        add(new PathPlanSequence(animCylinderTwist()));
        break;
        
      case PUPPET:
        add(new PathPlanSequence(lineGen()));
        break;
      
      case LINE:
        println(cubes[10].x, cubes[10].y, cubes[11].x, cubes[11].y);
        add(new PathPlanSequence(animRotateLine()));
        break;
        
      case WAVE:
        add(new PathPlanSequence(animWaveY()));
        break;

      default:
        add(new PathPlanSequence(animCylinderTwist()));
        break;
    }
    if (currSeq == null) {
      currSeq = sequences.get(0);
    }
    animState = animatorMode.TOINTERACTIVE;
    start();
    globalLoading = false; 
  }
  
  void startScreensaver() {
    untangleClear();
    stop();
    add(new PathPlanSequence(animCircle(0)));
    currSeq = sequences.get(0);
    guiState = GUImode.SCREENSAVER;
    animState = animatorMode.TOSCREENSAVER;
    start();
  }
  
  void stop() {
    stopAll();
    status = moveStatus.NONE;
  }
  
  void reset(){
    status = moveStatus.NONE;
    for (int i = 0; i < sequences.size(); i++) {
      sequences.get(i).reset();
    }
    iterator = 0;
    currSeq = sequences.get(0);
  }
  
  void restart() {
    reset();
    start();
  }
  
  void clear() {
    sequences.clear();
    iterator = 0;
    currSeq = null;
  }
  
    void skip(){
      untangling = false;
      if (currSeq.tangle) {
        untangling = true;
        currSeq = currSeq.genUntangle();
        stop(); start();
      } else if (iterator + 1 >= sequences.size()) {
        if (loop) {
          restart();
        } else {
          status = moveStatus.COMPLETE;
          if (animState == animatorMode.TOINTERACTIVE) {
            animState = animatorMode.INTERACTIVE;
            resetVariables();
            setupGUI();
            clear();
          }
        }
      } else {
        iterator++;
        currSeq = sequences.get(iterator);
        currSeq.start();
      }
  }
  
  void interactiveUpdate() {
      if (guiState != GUImode.SCREENSAVER) { 
        int[][][] targets;
        switch (guiChoose) {
          case CYLINDER:
            targets = animCylinderTwist();
            break;
          
          case LINE:
            targets = animRotateLine();
            break;
            
          case PUPPET:
            targets = translate(lineGen());
            break;
  
          case WAVE:
           targets = translate(animWaveY()); 
           break; 
          
          default:
            targets = animCylinderTwist();
            break;
        }
        
        visualize(targets);
    }
    
      if (animator.animState == animatorMode.INTERACTIVE)  {
        int[][][] targets;
        switch (realChoose) {
          case CYLINDER:
            targets = animCylinderTwist();
            break;
            
          case PUPPET:
            targets = translate(lineGen());
            break;
          
          case LINE:
            targets = animRotateLine();
            break;
  
          case WAVE:
             targets = translate(animWaveY()); 
             break; 
          
          default:
            targets = animCylinderTwist();
            break;
        }
        
        movePairsVelocity(targets);
    }
  }
  
  void update() {
    interactiveUpdate();
    
    if (animState == animatorMode.INTERACTIVE) {
      return;
    }
    
    boolean seqComplete = false;
    if (sequences.size() > 0) {
      seqComplete = currSeq.update(); 
    }
    
    if (seqComplete) {
      untangling = false;
      if (currSeq.tangle) {
        untangling = true;
        currSeq = currSeq.genUntangle();
        stop(); start();
      } else if (iterator + 1 >= sequences.size()) {
        if (loop) {
          restart();
        } else {
          if (animState == animatorMode.TOSCREENSAVER) {
            screensaver();
            animState = animatorMode.SCREENSAVER;
            guiState = GUImode.SCREENSAVER;
            resetVariables();
            setupGUI();
            setViz(true);
            setLoop(true);
          }
          else if (animState == animatorMode.TOINTERACTIVE) {
            animState = animatorMode.INTERACTIVE;
            guiState = GUImode.INTERACTIVE;
            resetVariables();
            setupGUI();
          } else {
            status = moveStatus.COMPLETE;
          }
        }
      } else {
        iterator++;
        currSeq = sequences.get(iterator);
        currSeq.start();
      }
    }
  }
  
  void untangle() {
    stop();
    if (animState == animatorMode.INTERACTIVE) {
      currSeq = new UntangleSequence();
    } else if (currSeq.tangle) {
      untangling = true;
      currSeq = currSeq.genUntangle();
    }
    start();
  }
  
  void untangleClear() {
    stop();
    if (untangling) {
      Sequence untangleSeq = currSeq;
      setLoop(false);
      clear();
      add(untangleSeq);
      currSeq = sequences.get(0);
    } else {
      setLoop(false);
      if (animState == animatorMode.INTERACTIVE) {
        untangling = true;
        clear();
        add(new UntangleSequence());
        currSeq = sequences.get(0);
      } else if (currSeq.tangle) {
        untangling = true;
        Sequence untangleSeq = currSeq.genUntangle();
        clear();
        add(untangleSeq);
        currSeq = sequences.get(0);
      } else {
        clear();
      }
    }
    start();
  }
  
  Sequence getCurrentSeq() {
    if (size() > 0) {
      return currSeq;
    }
    
    return null;
  }
  
  animatorMode getStatus() {
    return animState;
  }
  
  Sequence getSeq(int i) {
    return sequences.get(i);
  }
  
  int size() {
    return sequences.size();
  }
  
}

class Sequence {
  moveStatus status = moveStatus.NONE;
  boolean viz = false;
  boolean tangle = false;
  
  void start() {
    status = moveStatus.INPROGRESS;
  }
  
  void stop() {
    status = moveStatus.NONE;
  }
  
  void reset() {
    status = moveStatus.NONE;
  }
  
  void setViz(boolean val) {
    viz = val;
  }
  
  void setTangle(boolean val) {
    tangle = val;
  }
  
  void setTangle() {
    tangle = !tangle;
  }
  
  Sequence genUntangle(){
    return this;
  }
  
  boolean update(){
    return false;
  }
}

interface Movement  {
  int[][] get(float time);
}

interface IndependentMovement {
  int[][][] get(float time);
}



class SmoothSequence extends Sequence {
  moveType type;
  Movement func;
  IndependentMovement indieFunc;
  
  int startTime;
  int currTime;
  float timeLimit = 20;
  float period = 10;
  
  int[][] targets;
  int[][][] indieTargets;
  
  
  SmoothSequence(IndependentMovement newFunc) {
    type = moveType.INDEPENDENT;
    indieFunc = newFunc;
  }
  
  SmoothSequence(moveType tpe, Movement newFunc) {
    type = tpe;
    func = newFunc;
  }
  
  SmoothSequence(Movement newFunc) {
    type = moveType.PAIR;
    func = newFunc;
  }
  
  void start() {
    startTime = millis() - currTime;
    status = moveStatus.INPROGRESS;
  }
  
  void stop() {
    status = moveStatus.NONE;
  }
  
  void reset() {
    status = moveStatus.NONE;
    currTime = 0;
  }
  
  void setTimeLimit(float limit) {
    timeLimit = limit;
  }
  
  void setPeriod(float newPeriod) {
    period = newPeriod;
  }
  
  SmoothSequence genUntangle(){
    SmoothSequence untangleSeq;
    float timeElapsed = ((float) currTime/(period * 1000));
    if (type == moveType.INDEPENDENT) {
      untangleSeq = new SmoothSequence((float t) -> indieFunc.get(timeElapsed - t));
    } else {
      untangleSeq = new SmoothSequence(type, (float t) -> func.get(timeElapsed - t));
    }
    
    untangleSeq.setPeriod(period);
    untangleSeq.setTimeLimit((float) currTime/1000);
    untangleSeq.setViz(viz);
    
    return untangleSeq;
  }
  
  boolean update() {
    currTime = millis() - startTime;
    switch (type) {
      case TOP:
        targets = func.get((float) currTime/(period * 1000));
        for (int i = 0; i < targets.length; i++) {
          pairs[i].t.velocityTarget(targets[i][0], targets[i][1]);
          if (viz) pairsViz[i].t.target(targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
        
      case BOTTOM:
        targets = func.get((float) currTime/(period * 1000));
        for (int i = 0; i < targets.length; i++) {
          pairs[i].b.velocityTarget(targets[i][0], targets[i][1]);
          if (viz) pairsViz[i].b.target(targets[i][0], targets[i][1], targets[i][2]);
        }
      break;
      
      case PAIR:
        targets = func.get((float) currTime/(period * 1000));
        for (int i = 0; i < targets.length; i++) {
          pairs[i].velocityTarget(targets[i][0], targets[i][1]);
          if (viz) pairsViz[i].target(targets[i][0], targets[i][1], targets[i][2]);
        }
      break;
      
      case INDEPENDENT:
        indieTargets = indieFunc.get((float) currTime/(period * 1000));
        movePairsVelocity(indieTargets);
        if (viz) visualize(indieTargets);
      break;
    }
    if (currTime > (timeLimit * 1000)){
      status = moveStatus.COMPLETE;
      return true;
    }
    return false;
  }
}

class UntangleSequence extends Sequence {
  boolean started = false;
  boolean update() {
    switch (realChoose) {
      case CYLINDER:
        if (abs(t_offsetAngle - b_offsetAngle) < 0.25) {
          return true;
        } else if (!started) {
          if (t_offsetAngle > b_offsetAngle) {
              globalAngleOffsetSpeed = 0; //0.05;
              t_offsetAngleSpeed = 0; //=-0.05;
              b_offsetAngleSpeed =  0.75; //-0.05;
          } else {
              globalAngleOffsetSpeed = 0; //0.05;
              t_offsetAngleSpeed = 0; //=-0.05;
              b_offsetAngleSpeed = -0.75; //-0.05;
          }
        }
        
        int[][][] targets = animCylinderTwist();
        visualize(targets);
        movePairsVelocity(targets);
        return false;
        
      case LINE:
        return true;
        
      case PUPPET:
        return true;
      
      case WAVE:
        return true;
    }
    
    return false;
  } 
}


class DiscreteSequence extends Sequence {
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
    newFrame.setSpeed(speed);
    newFrame.setViz(viz);
    frames.add(newFrame);
  }
  
  void setSpeed(int newSpeed) {
    speed = newSpeed;
    for (Frame frame: frames) {
      frame.setSpeed(newSpeed);
    }
  }
  
  void setViz(boolean newViz) {
    viz = newViz;
    for (Frame frame: frames) {
      frame.setViz(viz);
    }
  }
  
  void start() {
    frames.get(iterator).execute();
    status = moveStatus.INPROGRESS;
  }
  
  void reset() {
    status = moveStatus.NONE;
    iterator = 0;
    
    for (int i = 0; i < frames.size(); i++) {
      frames.get(i).reset();
    }
  }
  
  DiscreteSequence genUntangle(){
    DiscreteSequence untangleSeq = new DiscreteSequence();

    for (int i = 0; i < size(); i++) {
      untangleSeq.addFrame(frames.get(size() - i - 1));
    }
    
    return untangleSeq;
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

class PathPlanSequence extends DiscreteSequence {
  int[][] finalTargets;
  PathPlanSequence(int[][] targets){
    finalTargets = targets;
    iterator = 0;
  }
  
  PathPlanSequence(int[][][] targets) {
    finalTargets = new int[nPairs][3];
    for (int i = 0; i < nPairs; i++) {
      finalTargets[i] = targets[i][1];
    }
    iterator = 0;
  }
  
  void start() {
    if (frames.size() == 0) {
      frames = planPath(finalTargets);
    } 
    
    frames.get(iterator).execute();
    status = moveStatus.INPROGRESS;
  }
}

class Frame {
  moveStatus status = moveStatus.NONE;
  moveType type;
  int speed = 80;
  boolean viz = false;
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
  
  void setViz(boolean newViz) {
     viz = newViz;
  }
  
  void execute() {
    status = moveStatus.INPROGRESS;
    switch(type) {
      case PAIR:
        for (int i = 0; i < targets.length; i++) {
          pairs[i].target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          if (viz) pairsViz[i].target(targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      
      case TOP:
        for (int i = 0; i < targets.length; i++) {
          pairs[i].t.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          if (viz) pairsViz[i].t.target(targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      
      case BOTTOM:
        for (int i = 0; i < targets.length; i++) {
          pairs[i].b.target(0, 5, 0, speed, 0, targets[i][0], targets[i][1], targets[i][2]);
          if (viz) pairsViz[i].b.target(targets[i][0], targets[i][1], targets[i][2]);
        }
        break;
      
      case INDEPENDENT:
        for (int i = 0; i < indieTargets.length; i++) {
          //paits[i].target(0,5,0,
          pairs[i].t.target(0, 5, 0, speed, 0, indieTargets[i][0][0], indieTargets[i][0][1], indieTargets[i][0][2]);
          pairs[i].b.target(0, 5, 0, speed, 0, indieTargets[i][1][0], indieTargets[i][1][1], indieTargets[i][1][2]);
        }
        visualize(indieTargets);
        break;
    }
  }
  
  void reset() {
    status = moveStatus.NONE;
  }
  
  boolean update() {
    moveStatus tempStatus = moveStatus.COMPLETE;
    for (int i = 0; i < pairs.length; i++) {
      switch (type) {
        case PAIR:
          if (viz) visualize(targets);
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
        if (viz) visualizeTop(targets);
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
          if (viz) visualizeBottom(targets);
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
        if (viz) visualize(targets);
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
