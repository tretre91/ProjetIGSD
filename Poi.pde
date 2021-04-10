public class Poi {
  private Map3D map;

  public Poi(Map3D map) {
    this.map = map;
  }

  public float minDist(PVector p, ArrayList<PVector> points) {
    float min = 10000.0f;
    for (PVector v: points) {
      float distance = dist(p.x, p.y, p.z, v.x, v.y, v.z);
      if (distance < min)
        min = distance;
    }
    return min;
  }

  public ArrayList<PVector> getPoints(String geojsonFile) {
    if (!fileExists(geojsonFile)) exit();

    JSONObject geojson = loadJSONObject(geojsonFile);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      exit();
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain feature collection.");
      exit();
    }

    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      exit();
    }

    ArrayList<PVector> points = new ArrayList<PVector>();
    JSONObject feature, geometry;
    JSONArray coordinates;
    Map3D.GeoPoint gp;
    Map3D.ObjectPoint op;

    for (int i = 0; i < features.size(); i++) {
      feature = features.getJSONObject(i);
      geometry = feature.getJSONObject("geometry");
      coordinates = geometry.getJSONArray("coordinates");

      gp = this.map.new GeoPoint(coordinates.getDouble(0), coordinates.getDouble(1));
      if (gp.inside()) {
        op = this.map.new ObjectPoint(gp);
        points.add(op.toVector());
      }
    }

    return points;
  }

}