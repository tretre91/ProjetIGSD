#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform bool showHeatmap;

smooth in vec4 vertHeat;

void main() {
  gl_FragColor = showHeatmap ? vertHeat : vec4(0.0);
}
