public class Camera {
  private static final float epsilon = 10e-6;
  
  private float x, y, z;
  private float radius;
  private float longitude;
  private float colatitude;
  
  private boolean lightning = false;
  
  public Camera() {
    radius = 2600.0f;
    longitude = -PI / 2.0;
    colatitude = PI / 4.0;
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
    z = cos(colatitude) * radius;
  }
  
  public void update() {
    ambientLight(0x60, 0x60, 0x60);
    if (lightning)
      directionalLight(0x70, 0x70, 0x40, 0, 0, -1);
    lightFalloff(0.0f, 0.0f, 1.0f);
    lightSpecular(0.0f, 0.0f, 0.0f);
    
    camera(
      x, y, z,
      0, 0, 0,
      0, 0, -1
    );
    
    //perspective(radians(80), width / height, 10.0f, 100000.0f);
  }
  
  public void toggle() {
    lightning = !lightning;
  }
  
  public float getRadius() { return radius; }
  public float getLongitude() { return longitude; }
  public float getColatitude() { return colatitude; }
  public float getLatitude() { return (PI / 2.0) - colatitude; }
  
  public void adjustRadius(float offset) {
    radius += offset;
    if (radius < width * 0.5)
      radius = width * 0.5;
    else if (radius > width * 3.0)
      radius = width * 3.0;
    
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
    z = cos(colatitude) * radius;
  }
  
  public void adjustLongitude(float delta) {
    longitude += delta;
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
  }
  
  public void adjustColatitude(float delta) {
    colatitude += delta;
    if (colatitude < epsilon)
      colatitude = epsilon;
    else if (colatitude > PI / 2)
      colatitude = PI / 2;
      
    x = cos(longitude) * cos(PI/2 - colatitude) * radius;
    y = -sin(longitude) * cos(PI/2 - colatitude) * radius;
    z = cos(colatitude) * radius;
  }
}
