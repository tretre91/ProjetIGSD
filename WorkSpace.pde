public class WorkSpace {
  private PShape gizmo;
  private PShape grid;
  
  /**
   * Creates a WorkSpace, consisting of a Gizmo and a size x size Grid
   */
  public WorkSpace(float size) {
    size = size / 100.0f;
    // gizmo
    gizmo = createShape();
    gizmo.beginShape(LINES);
    gizmo.noFill();
    gizmo.strokeWeight(3.0f);
    
    // X axis
    gizmo.stroke(0xAAFF3F7F);
    gizmo.vertex(0, 0, 0);
    gizmo.vertex(size, 0, 0);
    
    // Y axis
    gizmo.stroke(0xAA3FFF7F);
    gizmo.vertex(0, 0, 0);
    gizmo.vertex(0, size, 0);
    
    // Z axis
    gizmo.stroke(0xAA3F7FFF);
    gizmo.vertex(0, 0, 0);
    gizmo.vertex(0, 0, size);
    
    gizmo.strokeWeight(1.0f);
    // thin X axis
    gizmo.stroke(0xAAFF3F7F);
    gizmo.vertex(-50 * size, 0, 0);
    gizmo.vertex(50 * size, 0, 0);
    // thin Y axis
    gizmo.strokeWeight(0.7f);
    gizmo.stroke(0xAA3FFF7F);
    gizmo.vertex(0, -50 * size, 0);
    gizmo.vertex(0, 50 * size, 0);
    gizmo.endShape();
    
    //grid
    this.grid = createShape();
    this.grid.beginShape(QUADS);
    this.grid.noFill();
    this.grid.stroke(0x77836C3D);
    this.grid.strokeWeight(0.5f);
    float top, left;
    for (int i = -50; i < 50; i++) {
      top = i * size;
      for (int j = -50; j < 50; j++) {
        left = j * size;
        this.grid.vertex(left, top, 0);
        this.grid.vertex(left, top + size,0);
        this.grid.vertex(left + size, top + size,0);
        this.grid.vertex(left + size, top, 0);
      }
    }
    this.grid.endShape();
  }
  
  /**
   * Draws the gizmo
   */
  public void update() {
    shape(gizmo);
    shape(grid);
  }
  
  /**
   * Toggles Grid and Gizmo visibility
   */
  public void toggle() {
    final boolean visible = this.gizmo.isVisible();
    this.gizmo.setVisible(!visible);
    this.grid.setVisible(!visible);
  }
}
