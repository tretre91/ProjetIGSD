public class Camera {
  private static final float epsilon = 10e-6;
  
  private float x, y, z;
  private float radius;
  private float longitude;
  private float colatitude;
  
  private float lightX = 0.0f, lightY = 0.0f, lightZ = 1000.0f;
  private boolean lightning = false;
  
  /**
   * Creates a Camera object.
   * The camera's initial position is above the positive y axis, pointing to
   * the origin.
   */
  public Camera() {
    radius = 2600.0f;
    longitude = -PI / 2.0;
    colatitude = PI / 4.0;
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
    z = cos(colatitude) * radius;
  }
  
  /**
   * Refreshes the lighting and the camera.
   */
  public void update() {
    ambientLight(0x50, 0x50, 0x50);
    if (lightning) {
      pointLight(0x70, 0x70, 0x40, lightX, lightY, lightZ);
      fill(255, 255, 0);
      emissive(255, 255, 0);
    } else {
      fill(25, 25, 25);
      emissive(140, 140, 0);
    }
    lightFalloff(0.0f, 0.0f, 1.0f);
    lightSpecular(0.0f, 0.0f, 0.0f);
    
    pushMatrix();
    translate(lightX, lightY, lightZ);
    noStroke();
    sphere(50.0f);
    popMatrix();

    camera(
      x, y, z,
      0, 0, 0,
      0, 0, -1
    );
  }
  
  /**
   * Toggles the additional directional light.
   */
  public void toggle() {
    lightning = !lightning;
  }

  /**
   * Sets the direction of the directionnal light
   */
  public void setLightPosition(float x, float y, float z) {
    lightX = x;
    lightY = y;
    lightZ = z;
  }
  
  /**
   * Returns the camera's distance from the origin (its radius).
   */
  public float getRadius() { return radius; }

  /**
   * Returns the camera's longitude.
   */
  public float getLongitude() { return longitude; }

  /**
   * Returns the camera's colatitude.
   */
  public float getColatitude() { return colatitude; }

  /**
   * Returns the camera's colatitude (pi/2 - colatitude).
   */
  public float getLatitude() { return (PI / 2.0) - colatitude; }
  
  /**
   * Adjusts the camera's radius.
   * The radius is kept in the interval [0.5*width; 3*width], width being the
   * window's width.
   *
   * @param delta The value to add to the radius
   */
  public void adjustRadius(float delta) {
    radius = constrain(radius + delta, 0.5 * width, 3.0 * width);
    
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
    z = cos(colatitude) * radius;
  }
  
  /**
   * Adjusts the camera's longitude.
   * The longitude is always expressed between -3pi/2 and pi/2.
   *
   * @param delta The value (in radians) to add to the longitude
   */
  public void adjustLongitude(float delta) {
    longitude += delta;
    if (longitude < -3*PI / 2.0) {
      longitude = PI / 2.0 + (longitude % (-3*PI / 2.0));
    } else if (longitude > PI / 2.0) {
      longitude = - 3*PI / 2.0 + (longitude % (PI / 2.0));
    }
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
  }
  
  /**
   * Adjusts the camera's colatitude.
   * The colatitude is kept in the interval [0, pi/2].
   *
   * @param delta The value (in radians) to add to the colatitude
   */
  public void adjustColatitude(float delta) {
    colatitude = constrain(colatitude + delta, epsilon, HALF_PI);
      
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
    z = cos(colatitude) * radius;
  }
}
