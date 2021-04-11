uniform mat4 transformMatrix;

attribute vec4 position;
attribute vec4 heat;

smooth out vec4 vertHeat;

void main() {
  gl_Position = transformMatrix * position;
	vertHeat = heat / 255.0;
}