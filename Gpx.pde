import java.util.ArrayList;

public class Gpx {
  private PShape track;
  private PShape posts;
  private PShape thumbtacks;
  private ArrayList<String> descriptions;
  private int hitIndex = -1;
  private PVector hit;
  private boolean showDescription = true;
  private Camera camera;
  
  public Gpx(Map3D map, String geojsonFile, Camera camera) {
    this.camera = camera;
    this.descriptions = new ArrayList<String>();
    this.hit = new PVector();
    // Check ressources
    if (!fileExists(geojsonFile)) exit();
    
    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(geojsonFile);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      exit();
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain a feature collection.");
      exit();
    }
    
    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      exit();
    }
    
    
    this.posts = createShape();
    this.posts.beginShape(LINES);
    posts.stroke(color(255));
    posts.strokeWeight(1.0f);
    
    this.thumbtacks = createShape();
    this.thumbtacks.beginShape(POINTS);
    thumbtacks.stroke(color(255, 0, 0));
    thumbtacks.strokeWeight(7.0f);
    
    Map3D.ObjectPoint op;
            
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
      break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
        case "LineString":
          // GPX Track
          JSONArray coordinates = geometry.getJSONArray("coordinates");
          if (coordinates != null) {
            this.track = createShape();
            this.track.beginShape();
            this.track.noFill();
            this.track.stroke(color(193, 123, 208));
            this.track.strokeWeight(2.0f);
            
            for (int p=0; p < coordinates.size(); p++) {
              JSONArray point = coordinates.getJSONArray(p);
              op = map.new ObjectPoint(map.new GeoPoint(point.getDouble(0), point.getDouble(1)));  
              this.track.vertex(op.x, op.y, op.z);
            }
            this.track.endShape();
          }
          break;
          
        case "Point":
          // GPX WayPoint
          if (geometry.hasKey("coordinates")) {
            JSONArray point = geometry.getJSONArray("coordinates");
            String description = "Pas d'information.";
            if (feature.hasKey("properties")) {
              description = feature.getJSONObject("properties").getString("desc", description);
            }
            descriptions.add(description);
            op = map.new ObjectPoint(map.new GeoPoint(point.getDouble(0), point.getDouble(1)));
            
            this.posts.vertex(op.x, op.y, op.z);
            this.posts.vertex(op.x, op.y, op.z + 50.0f);
            this.thumbtacks.vertex(op.x, op.y, op.z + 50.0f);
          }
          break;
          
        default:
          println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + "' geometry type not handled.");
          break;
      }
    }
    
    this.posts.endShape();
    this.thumbtacks.endShape();
    
    track.setVisible(true);
    posts.setVisible(true);
    thumbtacks.setVisible(true);
  }
  
  public void update() {
    shape(track);
    shape(posts);
    shape(thumbtacks);
    
    if(showDescription && hitIndex != -1) {
      pushMatrix();
      lights();
      fill(0xFFFFFFFF);
      translate(hit.x, hit.y, hit.z + 10.0f);
      rotateZ(-this.camera.longitude-HALF_PI);
      rotateX(-this.camera.colatitude);
      g.hint(PConstants.DISABLE_DEPTH_TEST);
      textMode(SHAPE);
      textSize(48);
      textAlign(LEFT, CENTER);
      text(descriptions.get(hitIndex), 0, 0);
      g.hint(PConstants.ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
  
  public void toggle() {
    final boolean visible = track.isVisible();
    track.setVisible(!visible);
    posts.setVisible(!visible);
    thumbtacks.setVisible(!visible);
    showDescription = !visible;
  }
  
  public void clic(float x, float y) {
    float distance;
    hitIndex = -1;
    for(int v = 0; v < thumbtacks.getVertexCount(); v++) {
      if (hitIndex == -1) {
        thumbtacks.getVertex(v, hit);
        distance = dist(x, y, screenX(hit.x, hit.y, hit.z), screenY(hit.x, hit.y, hit.z));
        if (distance < 5.0f) {
          hitIndex = v;
          thumbtacks.setStroke(v, 0xFF3FFF7F);
          continue;
        }
      }
      thumbtacks.setStroke(v, 0xFFFF3F3F);
    }
  }
}
