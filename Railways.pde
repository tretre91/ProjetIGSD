public class Railways {
  private PShape rails;

  /**
   * Creates a Railways object.
   *
   * @param map         A Map3D object
   * @param geojsonFile The GeoJSON file containing informations about the railway
   */
  public Railways(Map3D map, String geojsonFile) {
    JSONArray features = getFeatures(geojsonFile);
    if (features == null) {
      rails = createShape();
      return;
    }

    rails = createShape(GROUP);
    color railsColor = #3992DD;
    PShape portion;

    Map3D.GeoPoint gp;
    Map3D.ObjectPoint op;
    JSONArray firstPoint, lastPoint;
    final float laneWidth = 10.0f;
    final double elevationOffset = 7.5d;

    for (int f = 0; f < features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry")) continue;
      JSONArray coordinates = feature.getJSONObject("geometry").getJSONArray("coordinates");
      if (coordinates != null) {
        portion = createShape();
        portion.beginShape(QUAD_STRIP);
        portion.stroke(railsColor);
        portion.strokeWeight(1.5);
        portion.fill(railsColor);

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
        // Drawing the first vertices corresponding to the first point
        if (opf.inside()) {
          JSONArray point = coordinates.getJSONArray(1);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          op = map.new ObjectPoint(gp);
          PVector ortho = new PVector(vf.y - op.y, op.x - vf.x).normalize().mult(laneWidth / 2.0f);
          portion.normal(0.0f, 0.0f, -1.0f);
          portion.vertex(vf.x - ortho.x, vf.y - ortho.y, vf.z);
          portion.normal(0.0f, 0.0f, -1.0f);
          portion.vertex(vf.x + ortho.x, vf.y + ortho.y, vf.z);
        }
        // the ones corresponding to the middle points
        for (int p = 1; p < coordinates.size() - 1; p++) {
          JSONArray point = coordinates.getJSONArray(p);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          if (gp.inside()) {
            gp.elevation += elevationOffset;
            op = map.new ObjectPoint(gp);
            portion.normal(0.0f, 0.0f, -1.0f);
            portion.vertex(op.x - vOrtho.x, op.y - vOrtho.x, op.z);
            portion.normal(0.0f, 0.0f, -1.0f);
            portion.vertex(op.x + vOrtho.x, op.y + vOrtho.x, op.z);
          }
        }
        // And the vertices corresponding to the last point
        if (opl.inside()) {
          JSONArray point = coordinates.getJSONArray(coordinates.size() - 2);
          gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          op = map.new ObjectPoint(gp);
          PVector ortho = new PVector(op.y - vl.y, vl.x - op.x).normalize().mult(laneWidth / 2.0f);
          portion.normal(0.0f, 0.0f, -1.0f);
          portion.vertex(vl.x - ortho.x, vl.y - ortho.y, vl.z);
          portion.normal(0.0f, 0.0f, -1.0f);
          portion.vertex(vl.x + ortho.x, vl.y + ortho.y, vl.z);
        }
        portion.endShape();
        rails.addChild(portion);
      }
    }

    rails.setVisible(true);
  }

  /**
   * Draws the railway.
   */
  public void update() {
    shape(rails);
  }

  /**
   * Toggles the railway's visibility.
   */
  public void toggle() {
    rails.setVisible(!rails.isVisible());
  }
}
