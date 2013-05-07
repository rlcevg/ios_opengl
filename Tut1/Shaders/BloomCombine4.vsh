#version 100

attribute vec2 texCoordVertex;

varying vec2 texCoord;

void main()
{
    gl_Position = vec4(texCoordVertex * 2.0 - 1.0, 0.0, 1.0);
    texCoord = texCoordVertex;
}
