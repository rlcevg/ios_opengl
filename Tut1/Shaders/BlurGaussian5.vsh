#version 100

attribute vec2 texCoordVertex;

uniform vec2 scale;
uniform float offsets[1];

varying vec2 texCoord;
varying vec2 blurTexCoords[2];

void main()
{
    gl_Position = vec4(texCoordVertex * 2.0 - 1.0, 0.0, 1.0);
    texCoord = texCoordVertex;

    blurTexCoords[0] = texCoord - offsets[0] * scale;
    blurTexCoords[1] = texCoord + offsets[0] * scale;
}
