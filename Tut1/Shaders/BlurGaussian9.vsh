#version 100

attribute vec2 texCoordVertex;

uniform vec2 texelSize;
uniform float offsets[2];

varying vec2 texCoord;
varying vec2 blurTexCoords[4];

void main()
{
    gl_Position = vec4(texCoordVertex * 2.0 - 1.0, 0.0, 1.0);
    texCoord = texCoordVertex;

    blurTexCoords[0] = texCoord - offsets[1] * texelSize;
    blurTexCoords[1] = texCoord - offsets[0] * texelSize;
    blurTexCoords[2] = texCoord + offsets[0] * texelSize;
    blurTexCoords[3] = texCoord + offsets[1] * texelSize;
}
