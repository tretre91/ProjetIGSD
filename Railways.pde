public class Railways {
  private PShape rails;
  
  public Railways(Map3D map, String geojsonFile) {
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
    
    rails = createShape(GROUP);
    PShape portion;
    
    Map3D.GeoPoint gp;
    Map3D.ObjectPoint op;
    
    for (int f = 0; f < features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry")) continue;
      JSONArray coordinates = feature.getJSONObject("geometry").getJSONArray("coordinates");
      if (coordinates != null) {
        portion = createShape();
        if (coordinates.size() == 2) 
          portion.beginShape(LINE_STRIP);
        else
          portion.beginShape();
        portion.stroke(color(0, 0, 255));
        portion.strokeWeight(3);
        portion.noFill();
        for (int p = 0; p < coordinates.size(); p++) {
          JSONArray point = coordinates.getJSONArray(p);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          if (gp.inside()) {
            op = map.new ObjectPoint(gp);
            portion.vertex(op.x, op.y, op.z+8);
            // certaines parties de la voie férrée se retrouvaient sous la map, d'ou le +12 en z
          }
        }
        portion.endShape();
        rails.addChild(portion);
      }
    }
    
    rails.setVisible(true);
  }
  
  public void update() {
    shape(rails);
  }
  
  public void toggle() {
    rails.setVisible(!rails.isVisible());
  }
  
}
