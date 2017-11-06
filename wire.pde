import java.util.*;

PlayGround pg;
boolean easy = false;

int waitStartTime;
int numberOfNodes = 4;

void setup() {
  pg = null;
  ArrayList<Node>  n;

  size(window.innerWidth - (0.02*window.innerWidth), window.innerHeight- (0.02*window.innerHeight)); 
  //size(640, 420);
  imageMode(CENTER);
  n = new ArrayList();
  for (int i = 0; i< numberOfNodes; i++) {
    n.add(new Node(new PVector(20, 20), new ArrayList<Node>()));
    n.get(i).setPosition((int)(Math.random() * width), (int)(Math.random() * height));
  }
  /*
  n[1].addNode(n[2]);
   n[3].addNode(n[2]);
   n[4].addNode(n[3]);
   n[4].addNode(n[5]);
   n[4].addNode(n[1]);
   n[4].addNode(n[2]);
   n[1].addNode(n[2]);
   */

  for (int i = 0; i < numberOfNodes; i++) {
    int a = (int)(Math.random() * numberOfNodes);
    int b =(int)(Math.random() * numberOfNodes);
    if (!n.get(a).others.contains(n.get(b)) && !n.get(b).others.contains(n.get(a))) {
      n.get(a).addNode(n.get(b));
    }
    if (!n.get(b).others.contains(n.get(a)) && !n.get(a).others.contains(n.get(b))) {
      n.get(b).addNode(n.get(a));
    }
  }
  for (Node node : n) {
    for (Node otherNode : n) {
      if (node.others.contains(otherNode) && !otherNode.others.contains(node)) {
        otherNode.addNode(node);
      }
      if (!node.others.contains(otherNode) && otherNode.others.contains(node)) {
        node.addNode(otherNode);
      }
    }
  }
  for (Node node : n) {
    int s = node.others.size();
    node.others.remove(node);
    if (s - node.others.size() != 0) {
    }
  }

  pg = new PlayGround();
  for (Node node : n) {
    if (node.others.size() > 0) {
      pg.addNode(node);
    }
  }
  pg.calculateSafes();
  pg.checkWin();
  if (pg.won) {
    setup();
  }


  background(13, 13, 44);   // Set the background to black
  pg.drawEdges();
  pg.drawNodes();
  pg.checkWin();
}


void draw() {  
  if (pg.selected != null) {
    background(13, 13, 44);   // Set the background to black
  }
  if (pg.won) {
    pg.drawGameOverScreen();
    if (millis() > waitStartTime + 3000) {
      numberOfNodes += int(random(5));
      setup();
    }
    return;
  }
  pg.loop();
}


void mousePressed() {  
  pg.handleMousePressed();
}


void mouseReleased() {  
  pg.handleMouseReleased();
}


class PlayGround {

  ArrayList<Node> nodes;
  Node selected;
  int clicks;
  int startTime;
  int time = 0;
  boolean won = false;
  float alpha = 0;
  PlayGround() {
    this.nodes = new ArrayList();
    this.clicks = 0;
    this.startTime = millis();
  }


  void addNode (Node node) {
    if (!this.nodes.contains(node)) {
      this.nodes.add(node);
    }
  }


  void calculateSafes() {
    for (Node node : this.nodes) {
      node.clearConflictOthers();
    }
    for (Node node1 : this.nodes) {
      for (Node otherNode1 : node1.others) {
        for (Node node2 : this.nodes) {
          for (Node otherNode2 : node2.others) {
            if (node1 == node2 ||
              otherNode1 == otherNode2 ||
              node1 == otherNode2 ||
              otherNode1 == otherNode2 ||
              otherNode1 == node2
              ) {
              break;
            }
            boolean result = doIntersect(
              node1.position.x, node1.position.y, 
              otherNode1.position.x, otherNode1.position.y, 
              node2.position.x, node2.position.y, 
              otherNode2.position.x, otherNode2.position.y
              );
            if (result) {
              node1.addConflictNode(otherNode1);
              otherNode1.addConflictNode(node1);

              node2.addConflictNode(otherNode2);
              otherNode2.addConflictNode(node2);
            }
          }
        }
      }
    }
  }


  boolean doIntersect (float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

    float a1, a2, b1, b2, c1, c2;
    float r1, r2, r3, r4;

    a1 = y2 - y1;
    b1 = x1 - x2;
    c1 = (x2 * y1) - (x1 * y2);

    r3 = ((a1 * x3) + (b1 * y3) + c1);
    r4 = ((a1 * x4) + (b1 * y4) + c1);

    if ((r3 != 0) && (r4 != 0) && same_sign(r3, r4)) {
      return false;
    }

    // Compute a2, b2, c2
    a2 = y4 - y3;
    b2 = x3 - x4;
    c2 = (x4 * y3) - (x3 * y4);

    // Compute r1 and r2
    r1 = (a2 * x1) + (b2 * y1) + c2;
    r2 = (a2 * x2) + (b2 * y2) + c2;

    if ((r1 != 0) && (r2 != 0) && (same_sign(r1, r2))) {
      return false;
    }
    return true;
  }


  boolean same_sign(float a, float b) {
    return a * b >= 0;
  }

  void drawEdges () {
    for (Node node : this.nodes) {
      for (Node otherNode : node.others) {
        if (this.won) {
          stroke(#34D63D);
        } else if (!node.isInConflictWith(otherNode)) {  
          stroke(255);
        } else {
          stroke(232, 3, 13);
        }
        line(node.position.x, node.position.y, otherNode.position.x, otherNode.position.y);
      }
    }
    stroke(0);
  }


  void drawNodes () {
    for (Node node : this.nodes) {
      node.draw();
    }
  }


  Node getBest(int x, int y) {
    Node ret = null;
    for (Node node : this.nodes) {
      if (dist(x, y, node.position.x, node.position.y) < node.size) {
        ret = node;
      }
    }
    return ret;
  }


  void drawGameOverScreen() {

    this.drawEdges();
    this.drawNodes();
    alpha = alpha + 1;
    fill(70,70,90, alpha * 0.2);
    rect(0, 0, width, height);      
    textSize(32);
    fill(#F4F7ED);
    text("You win: " + int(this.time / 1000) + " seconds", width * 0.02, min(height * 0.15 + this.alpha * 0.9, height * 0.20));
    // + this.clicks + " clicks, Time: " +5
  }


  void loop() {
    if (easy) {
      calculateSafes();
    }
    if (this.selected != null) {
      this.selected.setPosition(mouseX, mouseY);
      this.drawEdges();
      this.drawNodes();
      this.checkWin();
    }
  }

  boolean isWin() {
    for (Node node : this.nodes) {
      if (!node.isSafe()) {
        return false;
      }
    }
    return true;
  }

  void checkWin() {
    if (this.isWin()) {
      if (!this.won) {
        this.time = (millis() - this.startTime);
        waitStartTime = millis();
      }    

      this.won = true;
    }
  }

  void handleMouseReleased() {
    if (this.selected != null) {
      this.selected.isSelected = false;
    }
    this.selected = null;
    this.calculateSafes();
    this.drawEdges();
    this.drawNodes();
    this.checkWin();
  }

  void handleMousePressed() {
    Node best = getBest(mouseX, mouseY);
    if (best == null) {
      return;
    }
    best.isSelected = true;
    this.selected = best;
    this.clicks ++;
  }
}

class Node {
  PVector position; 
  ArrayList <Node> others;
  ArrayList <Node> conflictOthers;
  int size = (int)(width * 0.03);
  boolean isSelected;
  Node(PVector position, ArrayList <Node> others) {
    this.position = position;
    this.others = others;
    this.isSelected = false;
  }

  void draw() {
    if (this.isSelected) {      
      fill(3, 12, 211);
    } else if (!this.isSafe()) {
      fill(221, 4, 12);
    } else {
      fill(12, 214, 12);
    }
    ellipse(position.x, position.y, size, size);
    if (easy) {
      textSize(8);
      text(this.others.size(), position.x, position.y - 8);
    }
  }

  void addNode(Node node) {
    if (!this.others.contains(node)) {
      this.others.add(node);
    }
  }

  void addConflictNode(Node node) {
    if (conflictOthers == null) { 
      conflictOthers = new ArrayList();
    }
    if (!this.conflictOthers.contains(node)) {
      this.conflictOthers.add(node);
    }
  }


  boolean isSafe() {
    if (this.conflictOthers == null) {
      return true;
    }
    if (this.conflictOthers.size() == 0) {
      return true;
    }
    return false;
  }


  boolean isInConflictWith(Node node) {
    if (this.conflictOthers == null) {
      return false;
    }
    return this.conflictOthers.contains(node);
  }


  void clearConflictOthers() {
    this.conflictOthers = null;
  }


  void setPosition(int x, int y) {
    this.position.x = Math.min(Math.max(x, 0+this.size), width - this.size);
    this.position.y = Math.min(Math.max(y, 0+this.size), height - this.size);
  }
}