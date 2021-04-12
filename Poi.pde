public class Poi {
  private Map3D map;
  private static final int PRECISION = 20;
  private static final float RADIUS = 150.0f;
  private static final float ANGLE_INCREMENT = 2.0*PI/PRECISION;

  /**
   * Creates a Poi object.
   * This object is used to retrieve the position of points of interest which
   * are defined in a GeoJSON file.
   *
   * @param map A Map3D object
   */
  public Poi(Map3D map) {
    this.map = map;
  }

  /**
   * Creates a heatmap representing the distance from a type of point of interest.
   * The generated heatmap is stored in data/heatmap.png .
   *
   * @param colors       An array of colors to be applied for each type of point.
   *                     The same color can end up being used multiple times if 
   *                     the number of colors is less than the number of files.
   * @param geojsonFiles The names of the GeoJSON files containing the points of 
   *                     interest we want to represent, one or multiple files can
   *                     be specified.
   */
  public void createHeatmap(color[] colors, String... geojsonFiles) {
    if (colors.length == 0) {
      colors = new color[1];
      colors[0] = color(0,255,0);
    }

    PGraphics ghm = createGraphics(5000, 3000, P2D);
    ghm.smooth(8); 
    ghm.beginDraw();
    ghm.hint(DISABLE_DEPTH_MASK);
    ghm.hint(DISABLE_DEPTH_SORT);
    ghm.hint(DISABLE_DEPTH_TEST);
    ghm.hint(ENABLE_ASYNC_SAVEFRAME);
    ghm.pushMatrix();
    ghm.resetMatrix();
    ghm.clear();
    ghm.blendMode(BLEND);
    ghm.translate(2500.0f, 1500.0f);
    
    ghm.noStroke();
    for (int i = 0; i < geojsonFiles.length; i++) {
      final ArrayList<PVector> points = getPoints(geojsonFiles[i]);
      if (points.size() > 0) {
        color c = colors[i % colors.length];
        final PVector hmColor = new PVector(red(c), green(c), blue(c));

        for (PVector p: points) {
          ghm.beginShape(TRIANGLE_FAN);
          ghm.fill(hmColor.x, hmColor.y, hmColor.z, 150.0f);
          ghm.vertex(p.x, p.y);
          ghm.fill(hmColor.x, hmColor.y, hmColor.z, 0.0f);
          float angle = 0.0f;
          for (int j = 0; j <= PRECISION; j++) {
            ghm.vertex(p.x + RADIUS * cos(angle), p.y + RADIUS * sin(angle));
            angle += ANGLE_INCREMENT;
          }
          ghm.endShape();
        }
      }
    }

    ghm.popMatrix();
    ghm.save("data/heatmap.png");
    ghm.endDraw();
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