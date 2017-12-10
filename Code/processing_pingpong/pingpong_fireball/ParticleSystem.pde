class ParticleSystem {

  ArrayList particles; 
  PVector origin; 
  PImage img;
  
  ParticleSystem(int num, PVector v, PImage img_) {
    particles = new ArrayList();             
    origin = v.get();                      
    img = img_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img)); 
    }
  }

  void setOrigin(PVector newOrigin) {
    origin = newOrigin.get();
  }
  
  PVector getOrigin() {
    return origin;
  }
  
  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = (Particle) particles.get(i);
      p.run();
      if (p.dead()) {
        particles.remove(i);
      }
    }
  }
  
  // Method to add a force vector to all particles currently in the system
  void add_force(PVector dir) {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = (Particle) particles.get(i);
      p.add_force(dir);
    }
  
  }  

  void addParticle() {
    particles.add(new Particle(origin,img));
  }

  void addParticle(Particle p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}