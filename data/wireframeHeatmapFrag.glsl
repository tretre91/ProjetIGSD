#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform bool showHeatmap;

smooth in float vertHeat;

void main() {
	float intensity = showHeatmap ? 1.0 - smoothstep(vertHeat, 0.0, 50.0) : 0.0;
  gl_FragColor = vec4(intensity / 3.0, intensity, intensity / 3.0, intensity / 2.0);
}
