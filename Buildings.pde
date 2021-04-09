public class Buildings {
  private PShape buildings;
  Map3D map;
  
  public Buildings(Map3D map) {
    this.buildings = createShape(GROUP);
    this.map = map;
    buildings.setVisible(true);
  }
  
  public void add(String geojsonFile, int buildingColor) {
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
    
    PShape buildingsGroup = createShape(GROUP);
    PShape walls, roof;
    
    Map3D.GeoPoint gp;
    Map3D.ObjectPoint op;
    JSONObject geometry, properties;
    
    JSONArray point;
    ArrayList<PVector> points = new ArrayList<PVector>();
    
    for (int i = 0; i < features.size(); i++) {
      JSONObject feature = features.getJSONObject(i);
      geometry = feature.getJSONObject("geometry");
      properties = feature.getJSONObject("properties");
      int levels = properties.getInt("building:levels", 1);
      
      JSONArray coordinates = geometry.getJSONArray("coordinates");
      if (!(coordinates == null)) {
        for (int j = 0; j < coordinates.size(); j++) {
          float maxZ = -1.0f;
          JSONArray coords = coordinates.getJSONArray(j);
          for (int p = 0; p < coords.size(); p++) {
            point = coords.getJSONArray(p);
            gp = this.map.new GeoPoint(point.getDouble(0), point.getDouble(1));
            if (gp.inside()) {
              op = this.map.new ObjectPoint(gp);
              if (op.z > maxZ) maxZ = op.z;
              points.add(op.toVector());
            }
          }
          if (points.size() > 1) {
            points.add(points.get(0));
            
            final float top = maxZ + (Map3D.heightScale * 3.0f * levels); 
            walls = createShape();
            walls.beginShape(QUADS);
            walls.fill(buildingColor);
            walls.emissive(0x30);
            walls.noStroke();
            PVector previous = points.get(0);
            for (int k = 1; k < points.size(); k++) {
              final PVector v = points.get(k);
              final PVector vn = v.copy().sub(previous).cross(new PVector(0, 0, -1)).normalize();
              walls.normal(vn.x, vn.y, vn.z);
              walls.vertex(previous.x, previous.y, previous.z);
              walls.vertex(previous.x, previous.y, top);
              walls.vertex(v.x, v.y, top);
              walls.vertex(v.x, v.y, v.z);
              previous = v;
            }
            walls.endShape();
            
            roof = createShape();
            roof.beginShape(POLYGON);
            roof.fill(buildingColor);
            roof.emissive(0x60);
            roof.noStroke();
            for (PVector v: points) {
              roof.normal(0.0f, 0.0f, -1.0f);
              roof.vertex(v.x, v.y, top);
            }
            roof.endShape();
            
            buildingsGroup.addChild(walls);
            buildingsGroup.addChild(roof);
            points.clear();
          }
        }
      }
    }
    buildings.addChild(buildingsGroup);
  }
  
  public void update() {
    shape(buildings);
  }
  
  public void toggle() {
    buildings.setVisible(!buildings.isVisible());
  }
  
}
