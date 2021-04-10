public class Land {
  private PShape shadow;
  private PShape wireFrame;
  private PShape satellite;
  private Map3D map;
  private Poi poi;
  private PShader heatmapShader;
  private boolean showHeatmap = true;
  
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
    
    final int[] indices = {0,1,3,2};
    Map3D.ObjectPoint[] points = new Map3D.ObjectPoint[4];
    // Wireframe shape
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS);
    this.wireFrame.noFill();
    this.wireFrame.stroke(#888888);
    this.wireFrame.strokeWeight(0.5f);

    for (float i = -w/2; i < w/2; i += tileSize) {
      points[0] = this.map.new ObjectPoint(i, -h/2);
      points[1] = this.map.new ObjectPoint(i + tileSize, -h/2);
      for (float j = -h/2; j < h/2; j += tileSize) {
        points[2] = this.map.new ObjectPoint(i, j + tileSize);
        points[3] = this.map.new ObjectPoint(i + tileSize, j + tileSize);
        for (int k: indices) {
          this.wireFrame.vertex(points[k].x, points[k].y, points[k].z);
        }
        points[0] = points[2];
        points[1] = points[3];
      }
    }
    this.wireFrame.endShape();
    
    // Satellite shape
    if (!fileExists(textureFilename)) exit();
    this.heatmapShader = loadShader("heatmapFrag.glsl", "heatmapVert.glsl");
    this.heatmapShader.set("showHeatmap", showHeatmap);
    this.poi = new Poi(this.map);
    final ArrayList<PVector> pointsOfInterest = poi.getPoints("bus_stops.geojson");
    
    PImage uvmap = loadImage(textureFilename);
    final float uStep = (uvmap.width * tileSize) / w;
    final float vStep = (uvmap.height * tileSize) / h;
    float v, u = 0.0f;
    PVector[] normals = new PVector[4];
    float[] minDistances = new float[4];
    final PVector[] texOffsets = { new PVector(0,0,0), new PVector(uStep,0,0), new PVector(0,vStep,0), new PVector(uStep,vStep,0) };
    this.satellite = createShape();
    this.satellite.beginShape(QUADS);
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
    this.satellite.texture(uvmap);
    
    for (float i = -w/2; i < w/2; i += tileSize) {
      points[0] = this.map.new ObjectPoint(i, -h/2);
      normals[0] = points[0].toNormal();
      minDistances[0] = this.poi.minDist(points[0].toVector(), pointsOfInterest);
      points[1] = this.map.new ObjectPoint(i + tileSize, -h/2);
      normals[1] = points[1].toNormal();
      minDistances[1] = this.poi.minDist(points[1].toVector(), pointsOfInterest);
      v = 0.0f;
      for (float j = -h/2; j < h/2; j += tileSize) {
        points[2] = this.map.new ObjectPoint(i, j + tileSize);
        normals[2] = points[2].toNormal();
        minDistances[2] = this.poi.minDist(points[2].toVector(), pointsOfInterest);
        points[3] = this.map.new ObjectPoint(i + tileSize, j + tileSize);
        normals[3] = points[3].toNormal();
        minDistances[3] = this.poi.minDist(points[3].toVector(), pointsOfInterest);
        for (int k: indices) {
          this.satellite.attrib("heat", minDistances[k]);
          this.satellite.normal(normals[k].x, normals[k].y, normals[k].z);
          this.satellite.vertex(points[k].x, points[k].y, points[k].z, u + texOffsets[k].x, v + texOffsets[k].y);
        }
        for (int k = 0; k < 2; k++) {
          points[k] = points[k+2];
          normals[k] = normals[k+2];
          minDistances[k] = minDistances[k+2];
        }
        v += vStep;
      }
      u += uStep;
    }
    this.satellite.endShape();
    
    // Shapes initial visibility
    this.heatmapShader.set("showHeatmap", showHeatmap);
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }
  
  public void update() {
    shape(shadow);
    shape(wireFrame);
    shader(heatmapShader);
    shape(satellite);
    resetShader();
  }
  
  public void toggle() {
    final boolean visible = wireFrame.isVisible();
    this.wireFrame.setVisible(!visible);
    this.satellite.setVisible(visible);
  }

  public void toggleHeatmap() {
    this.showHeatmap = !this.showHeatmap;
    this.heatmapShader.set("showHeatmap", showHeatmap);
  }
  
}
