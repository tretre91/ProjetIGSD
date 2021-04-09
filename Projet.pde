WorkSpace workspace;
Camera cam;
Hud hud;
Map3D map;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
Buildings buildings;

/** Vérifie si un nom de fichier correspond à un fichier existant
 * @param filename Le nom du fichier à chercher
 * @return true si le fichier existe, false sinon
 */
public boolean fileExists(String filename) {
  File ressource = dataFile(filename);
  if (!ressource.exists() || ressource.isDirectory()) {
    println("ERROR: file " + filename + " not found.");
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
  this.map = new Map3D("paris_saclay.data");
  this.land = new Land(this.map, "paris_saclay_high_res.jpg");
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
  
  hint(ENABLE_KEY_REPEAT);
}

void draw() {
  background(64);
  cam.update();
  workspace.update();
  land.update();
  railways.update();
  roads.update();
  buildings.update();
  gpx.update();
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
        this.roads.toggle();
        break;
      
      case 'b':
      case 'B':
        this.buildings.toggle();
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
    cam.adjustColatitude((PI / 4) * (-dy / width));
  }
}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
