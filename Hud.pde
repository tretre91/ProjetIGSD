public class Hud {
  private PMatrix3D hud;
  private Camera camera;
  
  public Hud() {
    // Should be constructed just after P3D size() or fullScreen()
    this.hud = g.getMatrix((PMatrix3D) null);
    this.camera = null;
  }
  
  public Hud(Camera cam) {
    this.hud = g.getMatrix((PMatrix3D) null);
    this.camera = cam;
  }
  
  public void setCamera(Camera camera) {
    this.camera = camera;
  }
  
  private void begin() {
    g.noLights();
    g.pushMatrix();
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }
  
  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }
  
  private void displayFPS() {
    // Bottom left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, height-30, 60, 20, 5, 5, 5, 5);
    // Value
    fill(0xF0);
    textMode(SHAPE);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(String.valueOf((int)frameRate) + " fps", 40, height-20);
  }
  
  private void displayCamera() {
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, 30, 150, 80, 5, 5, 5, 5);
    fill(0xF0);
    textMode(SHAPE);
    // header
    textSize(18);
    textAlign(CENTER);
    text("Camera", 80, 45);
    // Labels
    textSize(14);
    textAlign(LEFT);
    text("Longitude", 15, 65);
    text("Latitude", 15, 85);
    text("Radius", 15, 105);
    //Values
    textAlign(RIGHT);
    String longitude = "-";
    String latitude = "-";
    String radius = "-";
    if (camera != null) {
      longitude = String.valueOf((int)round(degrees(camera.getLongitude()))) + "°";
      latitude = String.valueOf((int)round(degrees(camera.getLatitude()))) + "°";
      radius = String.valueOf((int)camera.getRadius()) + " m";
    }
    text(longitude, 155, 65);
    text(latitude, 155, 85);
    text(radius , 155, 105);
  }
  
  public void update() {
    this.begin();
    displayFPS();
    displayCamera();
    this.end();
  }
}
