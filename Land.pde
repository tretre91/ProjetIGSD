public class Land {
  private float landWidth, landHeight;
  private PShape shadow, wireFrame, satellite;
  private Map3D map;
  private Poi poi;
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
  * @param heatmap         A PImage holding the heatmap texture, such texture
  *                        can be generated using the Poi.createHeatmap() method
  */
  Land(Map3D map, String textureFilename, PImage heatmap) {
    final float tileSize = 25.0f;
    this.map = map;
    this.landWidth = (float)Map3D.width;
    this.landHeight = (float)Map3D.height;
    
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
    final int[] indices = {0,1,3,2};
    Map3D.ObjectPoint[] points = new Map3D.ObjectPoint[4];
    this.poi = new Poi(this.map);
    final ArrayList<PVector> pointsOfInterest = poi.getPoints("bus_stops.geojson");
    
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
    float v, u = 0.0f;
    final PVector[] texOffsets = { new PVector(0,0,0), new PVector(uStep,0,0), new PVector(0,vStep,0), new PVector(uStep,vStep,0) };

    PVector[] normals = new PVector[4];
    
    for (float i = -landWidth/2; i < landWidth/2; i += tileSize) {
      points[0] = this.map.new ObjectPoint(i, -landHeight/2);
      normals[0] = points[0].toNormal();
      points[1] = this.map.new ObjectPoint(i + tileSize, -landHeight/2);
      normals[1] = points[1].toNormal();
      v = 0.0f;
      for (float j = -landHeight/2; j < landHeight/2; j += tileSize) {
        points[2] = this.map.new ObjectPoint(i, j + tileSize);
        normals[2] = points[2].toNormal();
        points[3] = this.map.new ObjectPoint(i + tileSize, j + tileSize);
        normals[3] = points[3].toNormal();
        for (int k: indices) {
          final color heatColor = heatmap.pixels[pixelIndex(points[k].x, points[k].y, heatmap)];
          this.satellite.attrib("heat", red(heatColor), green(heatColor), blue(heatColor), alpha(heatColor));
          this.satellite.normal(normals[k].x, normals[k].y, normals[k].z);
          this.satellite.vertex(points[k].x, points[k].y, points[k].z, u + texOffsets[k].x, v + texOffsets[k].y);
          this.wireFrame.attrib("heat", red(heatColor), green(heatColor), blue(heatColor), alpha(heatColor));
          this.wireFrame.vertex(points[k].x, points[k].y, points[k].z);
        }
        for (int k = 0; k < 2; k++) {
          points[k] = points[k+2];
          normals[k] = normals[k+2];
        }
        v += vStep;
      }
      u += uStep;
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
