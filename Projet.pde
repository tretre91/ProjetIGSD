WorkSpace workspace;
Camera cam;
Hud hud;
Map3D map;
Land land;
Gpx gpx;
Railways railways;

/** Vérifie si un nom de fichier correspond à un fichier existant
 * @param filename Le nom du fichier à chercher
 * @return true si le fichier existe, false sinon
 */
public boolean fileExists(String filename) {
  File ressource = dataFile(filename);
  if (!ressource.exists() || ressource.isDirectory()) {
    println("ERROR: GeoJSON file " + filename + " not found.");
    return false;
  }
  return true;
}

void setup() {
  size(1500, 1000, P3D);
  //fullScreen(P3D);
  frameRate(60);
  smooth(8);
  workspace = new WorkSpace(250 * 100);
  cam = new Camera();
  hud = new Hud(cam);
  
  // load height map
  map = new Map3D("paris_saclay.data");
  land = new Land(this.map, "paris_saclay_high_res.jpg");
  gpx = new Gpx(this.map, "trail.geojson", cam);
  railways = new Railways(this.map, "export.geojson");
  
  hint(ENABLE_KEY_REPEAT);
}

void draw() {
  background(64);
  cam.update();
  workspace.update();
  land.update();
  gpx.update();
  railways.update();
  hud.update();
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        cam.adjustColatitude(-PI / 50.0);
        break;
      
      case DOWN:
        cam.adjustColatitude(PI / 50.0);
        break;
      
      case LEFT:
        cam.adjustLongitude(-PI / 50.0);
        break;
        
      case RIGHT:
        cam.adjustLongitude(PI / 50.0);
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
        cam.adjustRadius(-width * 0.1);
        break;
        
      case '-':
        cam.adjustRadius(width * 0.1);
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
    cam.adjustColatitude((PI / 4) * (-dy / height));
  }
}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
