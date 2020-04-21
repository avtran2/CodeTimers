/*
  CodeTimers
  by Alvin Tran  
  
  Read through a text file 
  Animate it according to the string    
  Use two timers to manipulate the sketch's display
 */
 

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      
String portName="/dev/tty.SLAB_USBtoUART";

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 0;

// Data coming in from the data fields
// data[0] = "1" or "0"                  -- BUTTON
// data[1] = 0-4095, e.g "2049"          -- POT VALUE
// data[2] = 0-4095, e.g. "1023"        -- LDR value
String [] data;

int switchValue=0;
int potValue=0;
int ldrValue=0;


// display for poem
PFont poetryFont;

// lines for the poem  
String[] lines;
int currentLineNum = 0;

// timing for poem
Timer displayTimer;
float timePerLine=0;
float minTimePerLine=100;
float maxTimePerLine=2000;
int defaultTimerPerLine=1500;

Timer textColorTimer;

// mapping pot values
float minPotValue=0;
float maxPotValue=4095;

//Image variables
PImage img;
PImage [] imageList;

//Booleans that tests whather strings equals "Cells.", "Interlinked.", or "Within cells interlinked."
boolean cells;
boolean interlinked;
boolean within;

//Different colors to be used
color black=color(0, 0, 0);
color red=color(255, 0, 0);
color white=color(255, 255, 255);
color grey=color(160, 160, 160);
color blue=color(0, 0, 255);

void setup ( ) {
  size (1200,  800);    
  
  textAlign(CENTER);
  poetryFont = createFont("Georgia", 32);
  
  imageList=new PImage[2];
  imageList[0]=loadImage("Interlinked.jpg");      
  imageList[1]=loadImage("WithinCells.jpg");                    
  
  // List all the available serial ports
  printArray(Serial.list());
  
  // Set the com port and the baud rate according to the Arduino IDE
  myPort=new Serial(this, Serial.list()[serialIndex], 115200); 
  
  
  // Allocate the timers
  displayTimer=new Timer(defaultTimerPerLine);
  textColorTimer=new Timer(1000);
  
   // settings for drawing the ball
  loadText();
  startText();
} 


// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have THREE items — ERROR-CHECK HERE
   if( data.length >= 3 ) 
   {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
      
      // change the display timer
      timePerLine = map( potValue, minPotValue, maxPotValue, minTimePerLine, maxTimePerLine );
      displayTimer.setTimer( int(timePerLine));
   }
  }
} 

//-- change background to red if we have a button
void draw ( ) {  
  if(mousePressed)//Able to check coordinates with mouse
  {
    int x=mouseX;
    int y=mouseY;
    println("X: "+x+" Y: "+y);
  }

  // every loop, look for serial information
  checkSerial();
  
  drawBackground();
  checkTimer();
  //drawText();
  
  if(cells==true)
  {
    cellBars();
  }
  else if(interlinked==true)
  {
    img=imageList[0];
    interLinks();
  }
  else if(within==true)
  {
    img=imageList[1];
    chains();
  }
  else
  {
      drawText();
  }

} 

// if input value is 1 (from ESP32, indicating a button has been pressed), change the background
void drawBackground() {
    background(white);       
}

void loadText() {
   lines=loadStrings("Baseline_Test.txt");
   
   // This shoes the poem lines in the debugger
  println("there are " + lines.length + " lines");
  for (int i = 0 ; i < lines.length; i++) 
  {
    println(lines[i]);
  }     
}

//-- resets all variables
void startText() {
  currentLineNum=0;
  displayTimer.start();
  textColorTimer.start();
}

//-- look at current value of the timer and change it
void checkTimer() {
  //-- if timer is expired, go to next  the line number
  if(displayTimer.expired()) 
  {
     currentLineNum++;
     
     // check to see if we are at the end of the poem, then go to zero
     if(currentLineNum==lines.length ) 
     {
       currentLineNum=0;
     }
       
     if(lines[currentLineNum].equals("Cells."))
     {
       cells=true;
     }
     else if(lines[currentLineNum].equals("Interlinked."))
     {
       interlinked=true;
     }
     else if(lines[currentLineNum].equals("Within cells interlinked."))
     {
       within=true;
     }
     else
     {
       cells=false;
       interlinked=false;
       within=false;
     }
       
     displayTimer.start();   
     textColorTimer.start();
  }
}

void cellBars(){
  if(textColorTimer.expired())
  {
    //-- TITLE
    fill(blue);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120);
  }
  else
  {
    //-- TITLE
    fill(black);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120); 
  }

  fill(grey);
  rect(100, 50, 120, 700);//1st from left bar      
  rect(300, 50, 120, 700);//2nd from left bar       
  rect(800, 50, 120, 700);//3rd from left bar 
  rect(1000, 50, 120, 700);//4th from left bar 
  
  fill(red);//New text to be displayed
  textFont(poetryFont);
  textSize(36);
  text(lines[currentLineNum], width/2, height/2 ); 
}

void interLinks(){ 
  if(textColorTimer.expired())
  {
    //-- TITLE
    fill(blue);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120);
  }
  else
  {
    //-- TITLE
    fill(black);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120); 
  }

  image(img, 380, 200); 
  
  fill(red);//New text to be displayed
  textFont(poetryFont);
  textSize(50);
  text(lines[currentLineNum], width/2, height/2); 
}
  
void chains(){    
  if(textColorTimer.expired())
  {
    //-- TITLE
    fill(blue);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120);
  }
  else
  {
    //-- TITLE
    fill(black);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120); 
  }

  image(img, 300, 150);  
  
  fill(red);//New text to be displayed
  textFont(poetryFont);
  textSize(50);
  text(lines[currentLineNum], width/2, height/2); 
}

//-- draw the Title (always the same)
//-- draw current line of poem
void drawText() {
  if(textColorTimer.expired())
  {
    //-- TITLE
    fill(blue);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120); 
  
    //-- CURRENT LINE (may be blank!)
    textFont(poetryFont);//Text that will be displayed if any of the booleans are false
    textSize(36);
    text(lines[currentLineNum], width/2, height/2 ); 
  }
  else
  {
    //-- TITLE
    fill(black);
    textSize(32);
    text("Baseline Test", width/2, 80); 
  
    textSize(20);
    text("Blade Runner 2049", width/2, 120); 
  
    //-- CURRENT LINE (may be blank!)
    textFont(poetryFont);//Text that will be displayed if any of the booleans are false
    textSize(36);
    text(lines[currentLineNum], width/2, height/2 ); 
  }
}
