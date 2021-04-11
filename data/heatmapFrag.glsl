#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform bool showHeatmap;

smooth in vec4 vertColor;
smooth in vec4 vertTexCoord;
smooth in vec4 vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  if (showHeatmap) {
    gl_FragColor = vec4(mix(gl_FragColor.rgb, vertHeat.rgb, vertHeat.a - 0.075), 1.0);
  }
}
