#version 100

attribute vec2 texCoordVertex;

uniform vec2 scale;
uniform float offsets[6];

varying vec2 texCoord;
varying vec2 blurTexCoords0;
varying vec2 blurTexCoords1;
varying vec2 blurTexCoords2;
varying vec2 blurTexCoords3;
varying vec2 blurTexCoords4;
varying vec2 blurTexCoords5;
varying vec2 blurTexCoords6;
varying vec2 blurTexCoords7;
varying vec2 blurTexCoords8;
varying vec2 blurTexCoords9;
varying vec2 blurTexCoords10;
varying vec2 blurTexCoords11;

void main()
{
    gl_Position = vec4(texCoordVertex * 2.0 - 1.0, 0.0, 1.0);
    texCoord = texCoordVertex;

    blurTexCoords0  = texCoord - offsets[5] * scale;
    blurTexCoords1  = texCoord - offsets[4] * scale;
    blurTexCoords2  = texCoord - offsets[3] * scale;
    blurTexCoords3  = texCoord - offsets[2] * scale;
    blurTexCoords4  = texCoord - offsets[1] * scale;
    blurTexCoords5  = texCoord - offsets[0] * scale;
    blurTexCoords6  = texCoord + offsets[0] * scale;
    blurTexCoords7  = texCoord + offsets[1] * scale;
    blurTexCoords8  = texCoord + offsets[2] * scale;
    blurTexCoords9  = texCoord + offsets[3] * scale;
    blurTexCoords10 = texCoord + offsets[4] * scale;
    blurTexCoords11 = texCoord + offsets[5] * scale;
}
