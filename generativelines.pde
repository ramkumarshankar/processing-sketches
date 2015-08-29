size(1600,1600);
background(0);

/*===========================================
Let's initialize colours
  - 4 dot colours
    - Blue - 78,205,196
    - Green - 199,244,100
    - Pink - 255,107,107
    - Red - 196,77,88
===========================================*/
color blueDot = color(78,205,196);
color greenDot = color(199,244,100);
color pinkDot = color(255,107,107);
color redDot = color(196,77,88);

/*===========================================
  - 3 line colours
    - Green - 209,242,165
    - Orange - 255,196,140
    - Pink - 245,105,145
===========================================*/
color greenLine = color(209,242,165);
color orangeLine = color(255,196,140);
color pinkLine = color(245,105,145);

//Draw the board
//Generate circles all over the board
for (int y = 20; y<=height-20; y+=20) {
  for (int x = 20; x<=width-20; x+=20) {
    fill(selectDotColor());
    noStroke();
    ellipse(x,y,10,10);
  }
}

//Randomize and show movement
/*===========================================
We are going to draw movement lines here from one point to another. There are some rules
1. Lines can only be drawn from a dot to one of the 8 adjacent dots.
2. The colour of the line will depend on the type of movement
  - Horizontal line - green
  - Vertical line - orange
  - Diagonal line - pink
===========================================*/
int movementLines = 1000;

/*===========================================
Three movement types are possible
  - Type 0 - horizontal line (left or right)
  - Type 1 - vertical line (above or below)
  - Type 2 - diagonal (any 4 diagonal sides)
===========================================*/
int movementType;

//Create random movement lines based on the movementLines variable
for (int i=0; i<=movementLines; i++) {
  movementType = int(random(4)%3);
  int x1 = selectDot();
  int y1 = selectDot();
  var endpoint = findEndpoint(movementType, x1, y1);
  color lineColor = color(selectLineColor(movementType));
  color shapeColor = get(x1,y1);
  strokeWeight(10);
  stroke(lineColor);
  line(x1, y1, endpoint[0], endpoint[1]);
  fill(shapeColor);
  noStroke();
  ellipse(endpoint[0], endpoint[1],10,10);
}

/*===========================================
selecDot()
  - parameters - NIL
  - randomly selects a particular dot to draw movement lines from
    either x or y coordinate returned
===========================================*/
function selectDot() {
  randomValue = (int(random(0,81))%80) * 20;
  if (randomValue == 0) {
    randomValue = 20;
  }
  return randomValue;
}

/*===========================================
findEndpoint()
  - parameters - movementType, x and y coordinates of starting point
  - returns endpoint x and y coordinates
  - Given a starting point and movement type (horizontal, vertical or diagonal),
    this function randomises the direction for that movement type and returns the
    coordinates of the end point.
===========================================*/
function findEndpoint(int type, int x, int y) {
  if (type == 0) {
    int direction = int(random(3) % 2);
    if (direction == 0) { //going left
      x -= 20;
    }
    else {
      x += 20;
    }
  } else if (type == 1) {
    int direction = int(random(3) % 2);
    if (direction == 0) { //going up
      y -= 20;
    }
    else { //going down
      y +=20;
    }
  } else if (type == 2) {
    int direction = int(random(4)%3);
    if (direction==0) { //top left
      x-=20;
      y-=20;
    }
    if (direction==1) { //top right
      x+=20;
      y-=20;
    }
    if (direction==2) { //bottom left
      x-=20;
      y+=20;
    }
    if (direction==3) { //bottom right
      x+=20;
      y+=20;
    }
  }
  //keep values constrained to board
  x = constrainValues(x);
  y = constrainValues(y);
  return [x,y];
}

/*===========================================
constrainValues
  - parameter - input x or y coordinate to be checked
  - returns modified value
  - When drawing random movement lines, if an endpoint falls outside the boundaries of the canvas,
    this function corrects the endpoints accordingly.
===========================================*/
function constrainValues(value) {
  if (value<20) {
    value = 20;
  }
  if (value>1580) {
    value = 1580;
  }
  return value;
}

/*===========================================
selectDotColor
  - parameters - NIL
  - returns dot colour
  - randomly returns a colour to be used for drawing the dots (circles)
===========================================*/
function selectDotColor() {
  int dotColor = int(random(5) % 4);
  switch(dotColor) {
    case 0:
      return blueDot;
      break;
    case 1:
      return greenDot;
      break;
    case 2:
      return pinkDot;
      break;
    case 3:
      return redDot;
      break;
  }
}

/*===========================================
selectLineColor
  - parameter - movementType (0 - horizontal, 1 - vertical, 2 - diagonal)
  - returns a colour
  - Given a movement type, the function selects the appropriate colour to be used for the line
===========================================*/
function selectLineColor(int type) {
  if (type == 0) {
    return greenLine;
  }
  else if (type == 1) {
    return orangeLine;
  }
  else {
    return pinkLine;
  }
}
