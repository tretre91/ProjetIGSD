WorkSpace workspace;
Camera cam;
Hud hud;
Map3D map;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
Buildings buildings;

int frameStart = 0;
final float CAMERA_SPEED = QUARTER_PI;
boolean moveUp = false, moveDown = false;
boolean moveLeft = false, moveRight = false;
boolean zoomIn = false, zoomOut = false;

final float LIGHT_Z = 1200.0f;

/**
 * Cheks if a file exists.
 * 
 * @param filename
 * @return true if the filename is associated with an existing file, false
 *         otherwise 
 */
boolean fileExists(String filename) {
  File ressource = dataFile(filename);
  if (!ressource.exists() || ressource.isDirectory()) {
    return false;
  }
  return true;
}

/**
 * Checks if a GeoJSON file is valid, and returns its features.
 * 
 * @param filename The GeoJSON file's name
 * @return The JSONArray corresponding to the 'features' key. Returns null if
 *         the file was not found or is not valid
 */
JSONArray getFeatures(String filename) {
  if (!fileExists(filename)) {
    println("ERROR: file " + filename + " not found.");
    return null;
  }

  JSONObject geojson = loadJSONObject(filename);
  if (!geojson.hasKey("type")) {
    println("WARNING: Invalid GeoJSON file.");
    return null;
  } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
    println("WARNING: GeoJSON file doesn't contain feature collection.");
    return null;
  }

  JSONArray features = geojson.getJSONArray("features");
  if (features == null) {
    println("WARNING: GeoJSON file doesn't contain any feature.");
  }
  return features;
}

void setup() {
  this.workspace = new WorkSpace(250 * 100);
  this.cam = new Camera();
  this.hud = new Hud(this.cam);
  
  // load height map
  this.map = new Map3D("paris_saclay.data");
  // Pour génerer une texture de carte de chaleur :
  // Poi poi = new Poi(this.map);
  // poi.createHeatmap(new color[]{color(0,255,0), color(255,0,0)}, "bus_stops.geojson", "atm.geojson");
  PImage heatmap = loadImage("heatmap.png");
  this.land = new Land(this.map, "paris_saclay_high_res.jpg", heatmap);
  this.gpx = new Gpx(this.map, "trail.geojson", cam);
  
  this.railways = new Railways(this.map, "railways.geojson");
  this.roads = new Roads(this.map, "roads.geojson");
  
  this.buildings = new Buildings(this.map);
  this.buildings.add("buildings_city.geojson", 0xFFaaaaaa);
  this.buildings.add("buildings_IPP.geojson", 0xFFCB9837);
  this.buildings.add("buildings_EDF_Danone.geojson", 0xFF3030FF);
  this.buildings.add("buildings_CEA_algorithmes.geojson", 0xFF30FF30);
  this.buildings.add("buildings_Thales.geojson", 0xFFFF3030);
  this.buildings.add("buildings_Paris_Saclay.geojson", 0xFFee00dd);
  
  size(1200, 800, P3D);
  //fullScreen(P3D);
  frameRate(60);
  smooth(8);
}

void draw() {
  background(64);
  processCamMovement(cam, (millis() - frameStart) / 1000.0f);
  frameStart = millis();
  cam.update();
  workspace.update();
  land.update();
  buildings.update();
  roads.update();
  noLights();
  railways.update();
  gpx.update();
  hud.update();
}

/**
 * Handles the camera's movements in case of a keyboard input.
 * Using the frametime allows fluid movements with a constant speed.
 *
 * @param camera The camera to move
 * @param frametime The framtime in seconds
 */
void processCamMovement(Camera camera, float frametime) {
  if (moveUp) camera.adjustColatitude(-CAMERA_SPEED * frametime);
  if (moveDown) camera.adjustColatitude(CAMERA_SPEED * frametime);
  if (moveLeft) camera.adjustLongitude(-CAMERA_SPEED * frametime);
  if (moveRight) camera.adjustLongitude(CAMERA_SPEED * frametime);
  if (zoomIn) camera.adjustRadius(-width * frametime);
  if (zoomOut) camera.adjustRadius(width * frametime);
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        moveUp = true;
        break;
      
      case DOWN:
        moveDown = true;
        break;
      
      case LEFT:
        moveLeft = true;
        break;
        
      case RIGHT:
        moveRight = true;
        break;
        
      default:
        break;
    }
  } else {
    switch (key) {
      case 'w':
      case 'W':
        //this.workspace.toggle();
        this.land.toggle();
        break;
      
      case '+':
        zoomIn = true;
        break;
        
      case '-':
        zoomOut = true;
        break;
      
      case 'l':
      case 'L':
        this.cam.toggle();
        break;
        
      case 'x':
      case 'X':
        this.gpx.toggle();
        break;
        
      case 'r':
      case 'R':
        this.railways.toggle();
        this.roads.toggle();
        break;
      
      case 'b':
      case 'B':
        this.buildings.toggle();
        break;

      case 'h':
      case 'H':
        this.land.toggleHeatmap();
        break;

      case '1':
        this.cam.setLightPosition(-(float)Map3D.width / 2.0f, (float)Map3D.height / 2.0f, LIGHT_Z);
        break;
      case '2':
        this.cam.setLightPosition(0.0f, (float)Map3D.height / 2.0f, LIGHT_Z);
        break;
      case '3':
        this.cam.setLightPosition((float)Map3D.width / 2.0f, (float)Map3D.height / 2.0f, LIGHT_Z);
        break;
      case '4':
        this.cam.setLightPosition(-(float)Map3D.width / 2.0f, 0.0f, LIGHT_Z);
        break;
      case '5':
        this.cam.setLightPosition(0.0f, 0.0f, LIGHT_Z);
        break;
      case '6':
        this.cam.setLightPosition((float)Map3D.width / 2.0f, 0.0f, LIGHT_Z);
        break;
      case '7':
        this.cam.setLightPosition(-(float)Map3D.width / 2.0f, -(float)Map3D.height / 2.0f, LIGHT_Z);
        break;
      case '8':
        this.cam.setLightPosition(0.0f, -(float)Map3D.height / 2.0f, LIGHT_Z);
        break;
      case '9':
        this.cam.setLightPosition((float)Map3D.width / 2.0f, -(float)Map3D.height / 2.0f, LIGHT_Z);
        break;
      
      default:
        break;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        moveUp = false;
        break;
      
      case DOWN:
        moveDown = false;
        break;
      
      case LEFT:
        moveLeft = false;
        break;
        
      case RIGHT:
        moveRight = false;
        break;
        
      default:
        break;
    }
  } else {
    switch (key) {
      case '+':
        zoomIn = false;
        break;

      case '-':
        zoomOut = false;
        break;
        
      default:
        break;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float ec = event.getCount();
  cam.adjustRadius(width * (ec / 10.0));
}

void mouseDragged() {
  if (mouseButton == CENTER) {
    float dx = mouseX - pmouseX;
    cam.adjustLongitude((-PI / 2) * (dx / width));
    float dy = mouseY - pmouseY;
    cam.adjustColatitude((PI / 2) * (-dy / width));
  }
}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
