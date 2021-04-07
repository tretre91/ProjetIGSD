public class Roads {
  private PShape roads;
  private class LaneProperties {
    public color laneColor;
    public double elevationOffset;
    public float laneWidth;
    
    public LaneProperties(String laneType) {
      switch (laneType) {
        case "motorway":
          this.laneColor = 0xFFe990a0;
          this.elevationOffset = 3.75d;
          this.laneWidth = 8.0f;
          break;
        case "trunk":
          this.laneColor = 0xFFfbb29a;
          this.elevationOffset = 3.60d;
          this.laneWidth = 7.0f;
          break;
        case "trunk_link":
        case "primary":
          this.laneColor = 0xFFfdd7a1;
          this.elevationOffset = 3.45d;
          this.laneWidth = 6.0f;
          break;
        case "secondary":
        case "primary_link":
          this.laneColor = 0xFFf6fabb;
          this.elevationOffset = 3.30d;
          this.laneWidth = 5.0f;
          break;
        case "tertiary":
        case "secondary_link":
          this.laneColor = 0xFFE2E5A9;
          this.elevationOffset = 3.15d;
          this.laneWidth = 4.0f;
          break;
        case "tertiary_link":
        case "residential":
        case "construction":
        case "living_street":
          this.laneColor = 0xFFB2B485;
          this.elevationOffset = 3.00d;
          this.laneWidth = 3.5f;
          break;
        case "corridor":
        case "cycleway":
        case "footway":
        case "path":
        case "pedestrian":
        case "service":
        case "steps":
        case "track":
        case "unclassified":
          this.laneColor = 0xFFcee8B9;
          this.elevationOffset = 2.85d;
          this.laneWidth = 1.0f;
          break;
        default:
          this.laneColor = 0xFFFF0000;
          this.elevationOffset = 1.50d;
          this.laneWidth = 0.5f;
          println("WARNING: Roads kind not handled : ", laneType);
          break;
      }
    }
  }
  
  public Roads(Map3D map, String geojsonFile) {
    this(map, geojsonFile, 0.0f);
  }
  
  public Roads(Map3D map, String geojsonFile, final float displayTreshold) {
    if (!fileExists(geojsonFile)) exit();
    
    JSONObject geojson = loadJSONObject(geojsonFile);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      exit();
    } else if(!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain feature collection.");
      exit();
    }
    
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      exit();
    }
    
    roads = createShape(GROUP);
    PShape portion;
    
    Map3D.GeoPoint gp;
    Map3D.ObjectPoint op;
    JSONArray firstPoint, lastPoint;
    color laneColor;
    float laneWidth;
    double elevationOffset;
    LaneProperties properties;
    
    for (int f = 0; f < features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry")) continue;
      JSONArray coordinates = feature.getJSONObject("geometry").getJSONArray("coordinates");
      if (coordinates != null) {
        properties = new LaneProperties(feature.getJSONObject("properties").getString("highway", "unclassified"));
        if (properties.laneWidth < displayTreshold) 
          continue;
        laneColor = properties.laneColor;
        laneWidth = properties.laneWidth;
        elevationOffset = properties.elevationOffset;
        
        portion = createShape();
        portion.beginShape(QUAD_STRIP);
        portion.emissive(0x89);
        portion.noStroke();
        portion.fill(laneColor);
        
        firstPoint = coordinates.getJSONArray(0);
        gp = map.new GeoPoint(firstPoint.getDouble(0), firstPoint.getDouble(1));
        gp.elevation += elevationOffset;
        final Map3D.ObjectPoint opf = map.new ObjectPoint(gp);
        final PVector vf = opf.toVector();
        
        lastPoint = coordinates.getJSONArray(coordinates.size() - 1);
        gp = map.new GeoPoint(lastPoint.getDouble(0), lastPoint.getDouble(1));
        gp.elevation += elevationOffset;
        final Map3D.ObjectPoint opl = map.new ObjectPoint(gp);
        final PVector vl = opl.toVector();
        
        final PVector vOrtho = new PVector(vf.y - vl.y, vl.x - vf.x).normalize().mult(laneWidth / 2.0f);
        // On dessine les vertex correspondant au 1er point 
        if (opf.inside()) {
          JSONArray point = coordinates.getJSONArray(1);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          op = map.new ObjectPoint(gp);
          PVector ortho = new PVector(vf.y - op.y, op.x - vf.x).normalize().mult(laneWidth / 2.0f);
          portion.normal(0.0f, 0.0f, 1.0f);
          portion.vertex(vf.x - ortho.x, vf.y - ortho.y, vf.z);
          portion.normal(0.0f, 0.0f, 1.0f);
          portion.vertex(vf.x + ortho.x, vf.y + ortho.y, vf.z);
        }
        // On dessine les éventuels points intermédiaires
        for (int p = 1; p < coordinates.size() - 1; p++) {
          JSONArray point = coordinates.getJSONArray(p);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          if (gp.inside()) {
            gp.elevation += elevationOffset;
            op = map.new ObjectPoint(gp);
            portion.normal(0.0f, 0.0f, 1.0f);
            portion.vertex(op.x - vOrtho.x, op.y - vOrtho.x, op.z);
            portion.normal(0.0f, 0.0f, 1.0f);
            portion.vertex(op.x + vOrtho.x, op.y + vOrtho.x, op.z);
          }
        }
        // On dessine les vertex correspondant au dernier point
        if (opl.inside()) {
          JSONArray point = coordinates.getJSONArray(coordinates.size() - 2);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          op = map.new ObjectPoint(gp);
          PVector ortho = new PVector(op.y - vl.y, vl.x - op.x).normalize().mult(laneWidth / 2.0f);
          portion.normal(0.0f, 0.0f, 1.0f);
          portion.vertex(vl.x - ortho.x, vl.y - ortho.y, vl.z);
          portion.normal(0.0f, 0.0f, 1.0f);
          portion.vertex(vl.x + ortho.x, vl.y + ortho.y, vl.z);
        }
        portion.endShape();
        roads.addChild(portion);
      }
    }
    
    roads.setVisible(true);
  }
  
  public void update() {
    shape(roads);
  }
  
  public void toggle() {
    roads.setVisible(!roads.isVisible());
  }
  
}
