public class Land {
  private float landWidth, landHeight;
  private PShape shadow, wireFrame, satellite;
  private Map3D map;
  private PShader heatmapShader, wfHeatmapShader;
  private boolean showHeatmap = true;
  
  /**
  * Creates a Land object.
  * This creates a land object with a wireframe representation, a textured
  * representation, and a shadow.
  *
  * @param map             Land associated elevation Map3D object
  * @param textureFilename The filename of the texture to apply to the land
  */
  Land(Map3D map, String textureFilename) {
    this(map, textureFilename, null);
  }
  
  /**
  * Creates a Land object paired with a heatmap.
  * This creates a land object with a wireframe representation, a textured
  * representation, a shadow, and a heatmap.
  *
  * @param map             Land associated elevation Map3D object
  * @param textureFilename The filename of the texture to apply to the land
  * @param heatmapTexture  The filename of a texture containing the heatmaps
  *                        to be applied on the Land object
  */
  Land(Map3D map, String textureFilename, String heatmapTexture) {
    final float tileSize = 25.0f;
    this.map = map;
    this.landWidth = (float)Map3D.width;
    this.landHeight = (float)Map3D.height;
    PImage heatmap = loadImage(heatmapTexture);
    
    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F);
    this.shadow.noStroke();
    this.shadow.vertex(-landWidth/2, -landHeight/2, -10.0f);
    this.shadow.vertex(-landWidth/2, landHeight/2, -10.0f);
    this.shadow.vertex(landWidth/2, landHeight/2, -10.0f);
    this.shadow.vertex(landWidth/2, -landHeight/2, -10.0f);
    this.shadow.endShape();
    
    if (!fileExists(textureFilename)) {
      this.wireFrame = createShape();
      this.satellite = createShape();
      return;
    }
    if (heatmap == null) {
      heatmap = createImage(2, 2, ARGB);
      heatmap.loadPixels();
      for (int i = 0; i < heatmap.pixels.length; i++) {
        heatmap.pixels[i] = color(0, 0, 0, 0);
      }
    }
    heatmap.loadPixels();
    
    // Wireframe shape
    this.wfHeatmapShader = loadShader("wireframeHeatmapFrag.glsl", "wireframeHeatmapVert.glsl");
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS);
    this.wireFrame.stroke(#888888);
    this.wireFrame.strokeWeight(0.5f);
    
    // Satellite shape
    this.heatmapShader = loadShader("heatmapFrag.glsl", "heatmapVert.glsl");
    this.satellite = createShape();
    this.satellite.beginShape(QUADS);
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
    PImage uvmap = loadImage(textureFilename);
    this.satellite.texture(uvmap);
    final float uStep = (uvmap.width * tileSize) / landWidth;
    final float vStep = (uvmap.height * tileSize) / landHeight;
    
    Map3D.ObjectPoint p1, p2, p3, p4;
    PVector n1, n2, n3, n4;

    for (float i = -landWidth/2, u = 0.0f; i < landWidth/2; i += tileSize, u += uStep) {
      p1 = this.map.new ObjectPoint(i, -landHeight/2);
      n1 = p1.toNormal();
      p2 = this.map.new ObjectPoint(i + tileSize, -landHeight/2);
      n2 = p2.toNormal();
      for (float j = -landHeight/2, v = 0.0f; j < landHeight/2; j += tileSize, v += vStep) {
        p3 = this.map.new ObjectPoint(i, j + tileSize);
        n3 = p3.toNormal();
        p4 = this.map.new ObjectPoint(i + tileSize, j + tileSize);
        n4 = p4.toNormal();
        
        addVertex(p1, n1, u, v, heatmap);
        addVertex(p2, n2, u + uStep, v, heatmap);
        addVertex(p4, n4, u + uStep, v  + vStep, heatmap);
        addVertex(p3, n3, u, v + vStep, heatmap);

        p1 = p3;
        n1 = n3;
        p2 = p4;
        n2 = n4;
      }
    }
    this.satellite.endShape();
    this.wireFrame.endShape();
    
    // Shapes initial visibility
    this.wfHeatmapShader.set("showHeatmap", showHeatmap);
    this.heatmapShader.set("showHeatmap", showHeatmap);
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }

  /**
   * Adds a vertex to the satellite and wireframe shapes.
   *
   * @param point   The point to add
   * @param normal  The point's normal vector
   * @param u, v    The point's coordinates on the texture
   * @param heatmap The heatmap texture to apply
   */
  void addVertex(Map3D.ObjectPoint point, PVector normal, float u, float v, PImage heatmap) {
    final color heatColor = heatmap.pixels[pixelIndex(point.x, point.y, heatmap)];
    this.satellite.attrib("heat", red(heatColor), green(heatColor), blue(heatColor), alpha(heatColor));
    this.satellite.normal(normal.x, normal.y, normal.z);
    this.satellite.vertex(point.x, point.y, point.z, u, v);
    this.wireFrame.attrib("heat", red(heatColor), green(heatColor), blue(heatColor), alpha(heatColor));
    this.wireFrame.vertex(point.x, point.y, point.z);
  }

  /**
   * Maps a point to the corresponding pixel's index in a PImage
   *
   * @param x     The x coordinate of the object point
   * @param y     The y coordinate of the object point
   * @param image A PImage
   * @return The index of the pixel the point would correspond to if the land
   *         and the image were the same size.
   */
  private int pixelIndex(float x, float y, PImage image) {
    final int imageX = round(map(x, -landWidth/2, landWidth/2, 0, image.width - 1));
    final int imageY = round(map(y, -landHeight/2, landHeight/2, 0, image.height - 1));
    return imageX + imageY * image.width;
  }

  /**
   * Draws The land, its shadow and the heatmap(s).
   */
  public void update() {
    shape(shadow);
    shader(wfHeatmapShader);
    shape(wireFrame);
    shader(heatmapShader);
    shape(satellite);
    resetShader();
  }
  
  /**
   * Switches between the textured and wireframe representations of the land.
   */
  public void toggle() {
    final boolean visible = wireFrame.isVisible();
    this.wireFrame.setVisible(!visible);
    this.satellite.setVisible(visible);
  }

  /**
   * Toggles the heatmaps' visibility.
   */
  public void toggleHeatmap() {
    this.showHeatmap = !this.showHeatmap;
    this.heatmapShader.set("showHeatmap", showHeatmap);
    this.wfHeatmapShader.set("showHeatmap", showHeatmap);
  }
  
}
