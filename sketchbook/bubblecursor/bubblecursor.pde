final int X = 0;
final int Y = 1;
final int DIAMETER = 2;

float[][] circles;
int numcircles;

boolean selectedTarget;
boolean won;

int trialNumber;
float avgTime;
float startTime;

boolean nonBubble;

void setup() {
   size(480, 480);
   smooth();
   numcircles = 10;
   circles = new float[numcircles][3];
   selectedTarget = false;
   won = false;
   trialNumber = 1;
   avgTime = 0;
   startTime = millis()/1000;
   newRandomCircles();
   nonBubble = false;
}

boolean overlappingLastCircle() {
  float[] lastCircle = circles[numcircles-1];
  for (int i=0; i<numcircles-1; i++) {
    float[] curCircle = circles[i];
    if (sqrt(sq(lastCircle[X]-curCircle[X])+sq(lastCircle[Y]-curCircle[Y])) < .5*curCircle[DIAMETER]) {
      return true;
    }
  }
  
  return false; 
}

void newRandomCircles() {
  for (int i=0; i<numcircles; i++) {
    circles[i][X] = random(40,440);
    circles[i][Y] = random(40,440);
    circles[i][DIAMETER] = random(5,80);
  }
  // in making the last circle, we have to make sure that it doesn't overlap other
  // circles, otherwise it will be sucksville when you try to click on it
  while(overlappingLastCircle()) {
    circles[numcircles-1][X] = random(40,440);
    circles[numcircles-1][Y] = random(40,440);
    circles[numcircles-1][DIAMETER] = random(5,80);
  }
}

void resetTimer() {
  float stopTime = millis()/1000.0;
  print("\nstart : " + startTime + "\nstop : " + stopTime + "\n for " + trialNumber + " trials\nprevious avg : " + avgTime); 
  avgTime = (((trialNumber-1) * avgTime) + (stopTime-startTime))/(trialNumber*1.0);
  trialNumber++;
  startTime = stopTime;
}

void randomCircles() {
  for (int i=0; i<numcircles-1; i++) {
     stroke(100);
     fill(255);
     ellipse(circles[i][X], circles[i][Y], circles[i][DIAMETER], circles[i][DIAMETER]);
  }
  noStroke();
  fill(0, 27, 180);
  ellipse(circles[numcircles-1][X], circles[numcircles-1][Y],
          circles[numcircles-1][DIAMETER], circles[numcircles-1][DIAMETER]);
}

float distanceToCircle(float[] circle) {
 // basic pythagorean theorem: c = sqrt(a^2 + b^2)
 // then we subtract the radius of the circle we're looking at to get the distance
 // to the edge
 float distance = sqrt(sq(mouseX-circle[X]) + sq(mouseY-circle[Y])) - .5*circle[DIAMETER];
 return distance;
}

float[] findClosestCircle() {
  float[] closestCircle = new float[4];
  float distance;
  float closestDistance=999;
  float secondClosestDistance=999;
  for(int i=0; i<numcircles; i++) {
    distance = distanceToCircle(circles[i]);
    if (distance < secondClosestDistance) {
      if(distance <= closestDistance) {
        secondClosestDistance = closestDistance;
        closestDistance = distance;
        closestCircle = circles[i];
        if (i == circles.length-1) {
          selectedTarget = true; 
        } else {
          selectedTarget = false;
        }
      } else {
        secondClosestDistance = distance; 
      }
    }
  }
  closestCircle = append(closestCircle, secondClosestDistance);
  return closestCircle;
}

float getBubbleDiameter(float[] closestCircle, float secondClosestDistance) {
  float closestContainDistance = distanceToCircle(closestCircle) + closestCircle[DIAMETER];
  return min(closestContainDistance, secondClosestDistance);
}

void bubbleCursor() {
  
  float[] closestCircleAndSecondDist = findClosestCircle();
  float secondClosestDistance = closestCircleAndSecondDist[closestCircleAndSecondDist.length - 1];
  float[] closestCircle = shorten(closestCircleAndSecondDist);
  
  // base bubble
  float rad = 2*getBubbleDiameter(closestCircle, secondClosestDistance);
  noStroke();
  fill(0,255,127);
  ellipse(mouseX, mouseY, rad, rad);
  if (rad == 2*secondClosestDistance) {
     // we don't have the other ellipse in our grasp!
     // put it in the mouse
     ellipse(closestCircle[X], closestCircle[Y], closestCircle[DIAMETER]+5, closestCircle[DIAMETER]+5); 
  }
}

void nonBubbleCursor() {
  float[] target = circles[numcircles-1];
  if (distanceToCircle(target) < 0) {
    selectedTarget = true;
  } else {
    selectedTarget = false;
  }
} 
  
void crosshairs() {
  stroke(0);
  line(mouseX-5, mouseY, mouseX+5, mouseY);
  line(mouseX, mouseY-5, mouseX, mouseY+5);
}

void header() {
  fill(255,0,0);
  text("trial " + trialNumber + " ; average time " + avgTime, 25,25); 
}

void draw() {
  background(255);
  if (nonBubble) {
    nonBubbleCursor();
  } else {
    bubbleCursor();
  }
  crosshairs();
  randomCircles();
  if(won) {
     newRandomCircles();
     resetTimer();
     won=false;
  }
  header();
}

void mouseClicked() {
  if (selectedTarget) {
     won = true;
   }
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    nonBubble = !(nonBubble);   
  }
}
