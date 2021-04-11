public class Poi {
  private Map3D map;

  /**
   * Creates a Poi object.
   * This object is used to retrive the positions of point of interest which
   * are defined in a GeoJSON file.
   *
   * @param map A Map3D object
   */
  public Poi(Map3D map) {
    this.map = map;
  }

  /**
   * Computes the distance between a point and the closest point in a list.
   *
   * @param p A point defined as a PVector
   * @param points The list of points we need to compare
   * @return The minimal distance between p and a point from points, or 10000.0
   *         if points was empty.
   */
  public float minDist(PVector p, ArrayList<PVector> points) {
    float min = 10000.0f;
    for (PVector v: points) {
      float distance = dist(p.x, p.y, p.z, v.x, v.y, v.z);
      if (distance < min)
        min = distance;
    }
    return min;
  }

  /**
   * Creates a list of points holding the positions of some points of interest.
   *
   * @param geojsonFile A GeoJSON file containing informations about points of
   *                    interest
   * @return An ArrayList<PVector> containing the points' positions
   */
  public ArrayList<PVector> getPoints(String geojsonFile) {
    JSONArray features = getFeatures(geojsonFile);
    ArrayList<PVector> points = new ArrayList<PVector>();

    if (features != null) {
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
    }

    return points;
  }

}