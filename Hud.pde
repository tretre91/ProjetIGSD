public class Hud {
  private PMatrix3D hud;
  private Camera camera;
  
  /**
   * Creates an HUD which only displays the framerate.
   * If you use this constructor you should then call setCamera in order to be
   * able to display the camera's informations.
   * An Hub object should be constructed before any modification to the default
   * matrix (ideally just after P3D size() or fullScreen()).
   */
  public Hud() {
    this.hud = g.getMatrix((PMatrix3D) null);
    this.camera = null;
  }
  
  /**
   * Creates a HUD which displays the framerate and informations about the camera.
   * An Hub object should be constructed before any modification to the default
   * matrix (ideally just after P3D size() or fullScreen()).
   *
   * @param cam The camera whose position informations will be displayed
   */
  public Hud(Camera camera) {
    this.hud = g.getMatrix((PMatrix3D) null);
    this.camera = camera;
  }
  
  /**
   * Associates a camera.
   * @param camera The camera whose informations will be displayed
   */
  public void setCamera(Camera camera) {
    this.camera = camera;
  }
  
  /**
   * Pushes the current state and prepares the drawing of the HUD.
   */
  private void begin() {
    g.noLights();
    g.pushMatrix();
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }
  
  /**
   * Pops the previously saved matrix and re-enables depth testing.
   */
  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }
  
  /**
   * Draws the FPS counter overlay.
   */
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
  
  /**
   * Draws the camera information overlay.
   */
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
      longitude = String.valueOf(round(degrees(camera.getLongitude()))) + "°";
      latitude = String.valueOf(round(degrees(camera.getLatitude()))) + "°";
      radius = String.valueOf(camera.getRadius()) + " m";
    }
    text(longitude, 155, 65);
    text(latitude, 155, 85);
    text(radius , 155, 105);
  }
  
  /**
   * Draws the HUD.
   */
  public void update() {
    this.begin();
    displayFPS();
    displayCamera();
    this.end();
  }
}
