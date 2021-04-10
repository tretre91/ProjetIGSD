#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform bool showHeatmap;

smooth in vec4 vertColor;
smooth in vec4 vertTexCoord;
smooth in float vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  if (showHeatmap) {
    gl_FragColor.g += (1.0 - smoothstep(vertHeat, 0.0, 50.0)) / 2.0;
  }
}
