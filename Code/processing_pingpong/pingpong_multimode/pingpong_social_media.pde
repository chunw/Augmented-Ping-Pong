import ddf.minim.*;

ArrayList staticObjects;
FallingObject[] objects;
int maxVel;
int scaler = 1;

PImage fb_notif_off;
PImage fb_notif_on;
PImage snap_unread;
PImage snap_read;
PImage call_read;
PImage call_unread;
PImage email_unread;
PImage email_read;
PImage message_read;
PImage message_unread;
PImage slack_read;
PImage instagram_read;

String[] social_media_sounds = new String[5];

void setupMode_social_media() { 
   if (player != null) {
    player.close();
   }
   player = minim.loadFile("sounds/combined.mp3");
   player.play(); 
   
   staticObjects = new ArrayList();
   
   initMedia();
   
   // falling objects
   maxVel = 6;
   objects = new FallingObject[30];
   
   for(int i = 0; i < objects.length; i++){
    
     PImage[] social_media_read_choices = { 
       fb_notif_off,
       snap_read,
       message_read,
       call_read,
       email_read,
       instagram_read,
       slack_read
     };
     int index = int(random(social_media_read_choices.length));
     objects[i] = new FallingObject(width, height, social_media_read_choices[index], true);
   }
}

void drawMode_social_media(){
  background(0);
  
  if (ballPosition != null && sensor.isRealHit()) {
     generateNotif();
   }
  
  // falling objects
  for(int i = 0; i < objects.length; i++) {
   objects[i].move();
   objects[i].draw();
  }
   
  // static objects
  for (int i = staticObjects.size()-1; i >= 0; i--) {
    FallingObject p = (FallingObject) staticObjects.get(i);
    p.drawAtStaticPos(p.x, p.y);
  }
  
  drawText();
}

void generateNotif() {
   PImage[] social_media_unread_choices = { 
       fb_notif_on,  
       message_unread,
       email_unread,
       snap_unread,
       call_unread
    };
   int index = int(random(social_media_unread_choices.length));
   if (staticObjects != null) {
     staticObjects.add(new FallingObject(ballPosition.x, ballPosition.y, social_media_unread_choices[index], false));
   
     //player = minim.loadFile(social_media_sounds[index]);
     //player.play(); 
   }
   
}

void initMedia() {
  fb_notif_off = loadImage("images/facebook - notification_off.png");
  fb_notif_on = loadImage("images/facebook - notification_on.png"); 
  snap_unread = loadImage("images/Snapchat-unread.png");
  snap_read = loadImage("images/Snapchat-read.png");
  message_read = loadImage("images/Messages-read.png");
  message_unread = loadImage("images/unread-messages.png");
  email_unread = loadImage("images/email-unread.png");
  email_read = loadImage("images/email-read.png");
  call_read = loadImage("images/read-call.png");
  call_unread = loadImage("images/unread_call.png");
  slack_read = loadImage("images/slack.png");
  instagram_read = loadImage("images/instagram.png");
  
  social_media_sounds[0] = "sounds/fb.mp3";
  social_media_sounds[1] = "sounds/message.mp3";
  social_media_sounds[2] = "sounds/email.mp3";
  social_media_sounds[3] = "sounds/snapchat.mp3";
  social_media_sounds[4] = "sounds/call.mp3";
  
}


void mousePressed() {
   ballPosition = new PVector(mouseX, mouseY);
   generateNotif();
}

class FallingObject{
   float x;
   float y;
   float vel;
   PImage img;
  
   FallingObject(float maxx, float maxy, PImage img, boolean randomize){
     if (randomize) {
       this.x = random(maxx);
       this.y = random(maxy);
     } else {
       this.x = maxx;
       this.y = maxy;
     }
     
     vel = random(maxVel);
     this.img = img;
   }

   void move(){
      x+=vel; // y+=vel; to view in normal mode. We want it to movve horizontally to work with projector
   }
   
   void draw() {
     image(img, x%width, y%height, img.width / scaler, img.height / scaler);
   }
   
   void drawAtStaticPos(float x, float y) {
     image(img, x, y, img.width / scaler, img.height / scaler);
   }
}