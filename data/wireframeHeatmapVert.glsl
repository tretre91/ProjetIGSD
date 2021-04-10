uniform mat4 transformMatrix;

attribute vec4 position;
attribute float heat;

smooth out float vertHeat;

void main() {
  gl_Position = transformMatrix * position;
	vertHeat = heat;
}