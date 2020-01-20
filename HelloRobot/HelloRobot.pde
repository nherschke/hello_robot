import processing.video.*;
import processing.serial.*;

Capture video;
PImage prev;
Serial port;

float threshold = 50;
float motionX = 0;
float motionY = 0;
float counterMotion = 0;
float lerpX = 0;
float lerpY = 0;

int lf = 10; // ASCII code for linefeed

void setup() {
  size(640, 360);
  textAlign(CENTER);

  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[63]); // Müsst ihr möglicherweise ändern, falls mehrere Kameraports verbaut
  video.start();

  printArray(Serial.list());
  port = new Serial(this, Serial.list()[0], 56700); // Müsst ihr möglicherweise ändern, falls ihr mehrere Ports habt
  port.clear();

  prev = createImage(640, 360, RGB);
}

void captureEvent(Capture video) {
  prev.copy(video, 0, 0, video.width, video.height, 0, 0, prev.width, prev.height);
  prev.updatePixels();
  video.read();
}

void draw() {
  video.loadPixels();
  prev.loadPixels();
  image(video, 0, 0);

  int count = 0;

  float avgX = 0;
  float avgY = 0;

  loadPixels();

  // Walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;

      // What is the current color?
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      color prevColor = prev.pixels[loc];
      float r2 = red(prevColor);
      float g2 = green(prevColor);
      float b2 = blue(prevColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d > threshold*threshold) {
        avgX += x;
        avgY += y;
        count++;
        pixels[loc] = color(255);
      } else {
        pixels[loc] = color(0);
      }
    }
  }
  updatePixels();

  if (count > 1000) {
    motionX = avgX / count;
    motionY = avgY / count;
    if (counterMotion < 100) counterMotion++;
  } else {
    if (counterMotion >= 5) counterMotion -= 5;
  }

  lerpX = lerp(lerpX, motionX, 0.1);
  lerpY = lerp(lerpY, motionY, 0.1);

  fill(0, 0, 255);
  strokeWeight(2.0);
  stroke(0);
  ellipse(lerpX, lerpY, 36, 36);

  fill(255, 0, 0);
  rect(20, 20, counterMotion, 20);
  
  fill(255, 255, 255);
  text(counterMotion, 70, 30);

  if (counterMotion == 100) {
    counterMotion = 0;
    float turnAngle = map(motionX, 0, width, 160, 20); // reverse camera x
    turnAngle = floor(turnAngle);
    port.write("STARTWAVING");
    port.write(" ");
    port.write(str(turnAngle));
    port.write(lf);
  }
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
  return d;
}
