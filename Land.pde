public class Land {
  private PShape shadow;
  private PShape wireFrame;
  private PShape satellite;
  private Map3D map;
  
  /**
  * Returns a Land object.
  * Prepares land shadow, wireframe and textured shape
  * @param map Land associated elevation Map3D object
  * @return Land object
  */
  Land(Map3D map, String textureFilename) {
    final float tileSize = 25.0f;
    this.map = map;
    float w = (float)Map3D.width;
    float h = (float)Map3D.height;
    
    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F);
    this.shadow.noStroke();
    this.shadow.vertex(-w/2, -h/2, -10.0f);
    this.shadow.vertex(-w/2, h/2, -10.0f);
    this.shadow.vertex(w/2, h/2, -10.0f);
    this.shadow.vertex(w/2, -h/2, -10.0f);
    this.shadow.endShape();
    
    // Wireframe shape
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS);
    this.wireFrame.noFill();
    this.wireFrame.stroke(#888888);
    this.wireFrame.strokeWeight(0.5f);
    Map3D.ObjectPoint v1, v2, v3, v4;
    for (float i = -w/2; i < w/2; i += tileSize) {
      v1 = this.map.new ObjectPoint(i, -h/2);
      v2 = this.map.new ObjectPoint(i + tileSize, -h/2);
      for (float j = -h/2; j < h/2; j += tileSize) {
        v3 = this.map.new ObjectPoint(i, j + tileSize);
        v4 = this.map.new ObjectPoint(i + tileSize, j + tileSize);
        this.wireFrame.vertex(v1.x, v1.y, v1.z);
        this.wireFrame.vertex(v2.x, v2.y, v2.z);
        this.wireFrame.vertex(v4.x, v4.y, v4.z);
        this.wireFrame.vertex(v3.x, v3.y, v3.z);
        v1 = v3;
        v2 = v4;
      }
    }
    this.wireFrame.endShape();
    
    // Satellite shape
    if (!fileExists(textureFilename)) exit();
    
    PImage uvmap = loadImage(textureFilename);
    final float uStep = (uvmap.width * tileSize) / w;
    final float vStep = (uvmap.height * tileSize) / h;
    float v, u = 0.0f;
    PVector n1, n2, n3, n4;
    this.satellite = createShape();
    this.satellite.beginShape(QUADS);
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
    this.satellite.texture(uvmap);
    
    for (float i = -w/2; i < w/2; i += tileSize) {
      v1 = this.map.new ObjectPoint(i, -h/2);
      n1 = v1.toNormal();
      v2 = this.map.new ObjectPoint(i + tileSize, -h/2);
      n2 = v2.toNormal();
      v = 0.0f;
      for (float j = -h/2; j < h/2; j += tileSize) {
        v3 = this.map.new ObjectPoint(i, j + tileSize);
        n3 = v3.toNormal();
        v4 = this.map.new ObjectPoint(i + tileSize, j + tileSize);
        n4 = v4.toNormal();
        this.satellite.normal(n1.x, n1.y, n1.z);
        this.satellite.vertex(v1.x, v1.y, v1.z, u, v);
        this.satellite.normal(n2.x, n2.y, n2.z);
        this.satellite.vertex(v2.x, v2.y, v2.z, u + uStep, v);
        this.satellite.normal(n4.x, n4.y, n4.z);
        this.satellite.vertex(v4.x, v4.y, v4.z, u + uStep, v + vStep);
        this.satellite.normal(n3.x, n3.y, n3.z);
        this.satellite.vertex(v3.x, v3.y, v3.z, u, v + vStep);
        v1 = v3;
        n1 = n3;
        v2 = v4;
        n2 = n4;
        v += vStep;
      }
      u += uStep;
    }
    this.satellite.endShape();
    
    // Shapes initial visibility
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }
  
  public void update() {
    shape(shadow);
    shape(wireFrame);
    shape(satellite);
  }
  
  public void toggle() {
    final boolean visible = wireFrame.isVisible();
    this.wireFrame.setVisible(!visible);
    this.satellite.setVisible(visible);
  }
  
}
