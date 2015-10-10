/* @pjs font="/media/css/Chunkfive-webfont.ttf"; */
/** @peep sketch */

color lightBlue = color(66, 168, 237);
color darkBlue = color(0, 102, 153);
color orange = color(204, 102, 0);

//Add my colour
color lightBlueAlpha = color(66, 168, 237, 100);
color darkBlueAlpha = color(0, 102, 153, 75);
color orangeAlpha = color(204, 102, 0, 50);

PFont chunkfive;
String tagline = "Learn to Program. Creatively.";

//Initial number of circles
int numCirclesLarge;
int numCirclesSmall;
int thresholdRadius = 30;

//Number of large circles destroyed
int largeCirclesDestroyed = 0;

//Number of circles to add when a large circle disappears
int numSmallCirclesAdd;

//Maximum number of allowed circles on the canvas, used to keep animation from going out of hand
int maximumNumberOfCircles;

//Initialize arrays
MyCircle[] circles = new MyCircle[numCirclesLarge + numCirclesSmall];
Explosion[] explosions = new Explosions[0];

//Initialize arrays to keep track of circles to remove
int[] circlesToRemove = new int[0];

//Easing value to control tweening speed
float easing = 0.05;

void setup() {
  // Set the size of the sketch to half height of the banner to fit in a portfolio post
  //size(500, 212); // Change to (1000, 414) to see how it might look in the banner position
  //Larger size to test
  size(1000,414);
  // Calculate the size of the tagline based on the height of the sketch
  int taglineHeight = 3*height/40;
  // Load the Chunkfive font from the website at the calculated size
  chunkfive = createFont("/media/css/Chunkfive-webfont.ttf", taglineHeight);

  //Calculate starting number of circles to display and other variables based on size of sketch
  numCirclesLarge = int((4/500)*width);
  numCirclesSmall = int((10/500)*width);
  numSmallCirclesAdd = int((2/500)*width);
  maximumNumberOfCircles = int((30/500)*width);

  int totalCircles = numCirclesLarge + numCirclesSmall;

  for (int i = 0; i < numCirclesLarge; i++) {
    circles[i] = new MyCircle(1);
  }
  for (int i = numCirclesLarge; i < totalCircles; i++) {
    circles[i] = new MyCircle(0);
  }
}

void draw() {
  background(255);
  for (int i = 0; i < circles.length; i++) {
    for (int j = 0; j < circles.length; j++) {
      //check for collisions
      if (i != j) {
        if (circles[i].mySize == circles[j].mySize) {
          //collisions happen between small circles only or large circles only
          circles[i].checkCollision(circles[j]);
        }
      }
    }
    //check if a small circle has grown up
    circles[i].alterSize();
    //move each circle
    circles[i].moveCircle();
    //draw the circles
    circles[i].renderCircle();
  }

  //render the explosions
  for (int i = 0; i < explosions.length; i++) {
    explosions[i].renderExplosion();
  }
  fill(lightBlue);
  // Set the text font to use Chunkfive
  textFont(chunkfive);
  // Set the text alignment to be centred in the window
  textAlign(CENTER, CENTER);
  // Draw the tagline in the sketch
  text(tagline, width/2, height/2);
  //cleanup circles and explosions
  cleanupCircles();
  cleanupExplosions();
  //if we have removed any large circles, and there is room on the canvas
  //add more small circles
  if ((largeCirclesDestroyed > 0) && (totalCircles < maximumNumberOfCircles)) {
    for (int i = 0; i < largeCirclesDestroyed; i++) {
      for (int j = 0; j < numSmallCirclesAdd; j++) {
        circles.push(new MyCircle(0));
      }
    }
  }
  //reset the counter
  largeCirclesDestroyed=0;
}

//remove small circles with radius = 0 and large circles which have collided
void cleanupCircles() {
  //make a list of circles to remove
  for (int i = 0; i < circles.length; i++) {
    if (circles[i].mySize == 0) {
      //cleanup small circles if their radius = 0
      if ((circles[i].radius == 0) && (circles[i].tweeningProgress==false)) {
        circlesToRemove.push(i);
      }
    }
    if (circles[i].mySize == 1) {
      //cleanup large circles if they are colliding
      if (circles[i].colliding == true) {
        circlesToRemove.push(i);
        //keep a counter of how many large circles we are removing
        largeCirclesDestroyed++;
      }
    }
  }
  //Sort the list of circles to remove in descending order
  //so we remove items from the circles array starting from the end
  //Removing items in the middle of an array in the loop can result in weird behaviour
  circlesToRemove.sort(function(a,b){return b - a});

  //Remove circles we don't need
  for (int i = 0; i < circlesToRemove.length; i++) {
    circles.splice(circlesToRemove[i], 1);
    totalCircles--;
  }

  //Empty the list array
  circlesToRemove.length = 0;
  //Update the counter of number of circles on the canvas
  totalCircles = circles.length;
}

void cleanupExplosions() {
  for (int i = 0; i < explosions.length; i++) {
    if (explosions[i].completed) {
      //if explosions are completed, remove them from array
      explosions.splice(i,1);
    }
  }
}


class MyCircle {
  PVector position = new PVector(random(width), random(height));
  PVector velocity = new PVector(random(-0.5,0.5), random(-0.5,0.5));
  float radius;
  float newRadius;
  bool tweeningProgress = false; //indicates if tweening is in progress (small circles only)
  bool colliding = false; //only used for large circles
  int mySize; //0 - small circle, 1 - large circle

  MyCircle(int _size) {
    //size = 0 if circles are small
    if (_size == 0) {
      newRadius =  random(10,20);
      radius = 0;
      mySize = _size;
    }
    //size = 1 if circles are large
    if (_size == 1) {
      radius =  random(40,60);
      newRadius = radius;
      mySize = _size;
    }
  }

  void moveCircle () {
    position.add(velocity);
    if ((position.x > width) || (position.x < 0)) {
      velocity.x = velocity.x * -1;
    }
    if (position.y > height || (position.y < 0)) {
      velocity.y = velocity.y * -1;
    }
  }

  void renderCircle () {
    if (newRadius != radius) {
      radius += (newRadius - radius) * easing;
      //If values are very close, mark tweening a completed.
      if (abs(newRadius - radius) <= easing) {
        radius = newRadius;
        tweeningProgress = false;
      }
    }
    if (newRadius == radius) {
      tweeningProgress = false;
    }
    noStroke();
    if (mySize == 0) {
      //draw a small circle
      stroke(lightBlue);
      strokeWeight(1);
      noFill();
    }
    else if (mySize == 1) {
      //draw a large circle
      noStroke();
      fill(darkBlueAlpha);
    }
    ellipse(position.x, position.y, radius, radius);
  }

  void alterSize() {
    //If a circle has a radius > threshold value, it's considered a large circle
    if (radius <= thresholdRadius) {
      mySize = 0;
    }
    else {
      mySize = 1;
    }
  }

  void checkCollision (MyCircle otherCircle) {
    if (PVector.dist(this.position, otherCircle.position) <= ((this.radius+otherCircle.radius)/2)) {
      //if two small circles collide
      if ((this.mySize == 0) && (otherCircle.mySize == 0)) {
        //Make one circle absorb the other
        if ((this.newRadius >= otherCircle.newRadius) && (this.tweeningProgress == false)) {
          this.tweeningProgress = true;
          this.newRadius += otherCircle.newRadius;
          otherCircle.tweeningProgress = true
          otherCircle.newRadius = 0;
        }
        if ((otherCircle.newRadius > this.newRadius) && (otherCircle.tweeningProgress == false)) {
          otherCircle.tweeningProgress = true;
          otherCircle.newRadius += this.newRadius;
          this.tweeningProgress = true;
          this.newRadius = 0;
        }
      }
      //if two large circles collide
      if ((this.mySize == 1) && (otherCircle.mySize == 1)) {
        //and both are not already colliding with another
        if ((this.colliding == false) && (otherCircle.colliding == false)) {
          PVector centrePoint = new PVector.add(this.position, otherCircle.position);
          centrePoint.div(2);
          //create a new explosion at the centre point
          explosions.push(new Explosion(centrePoint.x, centrePoint.y));
          //Mark both circles as colliding, so we know to remove them in the cleanup routine.
          this.colliding = true;
          otherCircle.colliding = true;
        }
      }
    }
  }
}

class Explosion {
  PVector location;
  int startRadius = 10;
  int endRadius = 50;
  bool completed = false;

  Explosion(int x, int y) {
    location = new PVector(x, y);
  }

  void renderExplosion () {
    if (endRadius != startRadius) {
      startRadius += (endRadius - startRadius) * easing;
      //If values are very close, mark tweening a completed.
      if (abs(endRadius - startRadius) <= easing) {
        startRadius = endRadius;
        //if explosion has reached endRadius, shrink it down before removing it
        if (endRadius == 50) {
          endRadius = 0;
        }
        else {
          completed = true;
        }
      }
    }
    if (endRadius == startRadius) {
      //mark as completed if explosion is done, so we know to remove them in the cleanup
      completed = true;
    }
    noStroke();
    fill(orangeAlpha);
    ellipse(location.x, location.y, startRadius, startRadius);
  }
}
