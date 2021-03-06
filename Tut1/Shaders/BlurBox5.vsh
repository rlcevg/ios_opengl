#version 100

attribute vec2 texCoordVertex;

uniform vec2 texelSize;

//varying vec2 texCoord;
varying vec2 blurTexCoords[8];

void main()
{
    gl_Position = vec4(texCoordVertex * 2.0 - 1.0, 0.0, 1.0);
//    texCoord = texCoordVertex;

//    blurTexCoords[0] = texCoordVertex - 1.5 * texelSize;
//    blurTexCoords[1] = texCoordVertex - 0.5 * texelSize;
//    blurTexCoords[2] = texCoordVertex + 0.5 * texelSize;
//    blurTexCoords[3] = texCoordVertex + 1.5 * texelSize;

    blurTexCoords[0] = texCoordVertex + vec2(-1.5, -1.5) * texelSize;
    blurTexCoords[1] = texCoordVertex + vec2( 0.0, -1.5) * texelSize;
    blurTexCoords[2] = texCoordVertex + vec2( 1.5, -1.5) * texelSize;
    blurTexCoords[3] = texCoordVertex + vec2(-1.5,  0.0) * texelSize;
    blurTexCoords[4] = texCoordVertex + vec2( 1.5,  0.0) * texelSize;
    blurTexCoords[5] = texCoordVertex + vec2(-1.5,  1.5) * texelSize;
    blurTexCoords[6] = texCoordVertex + vec2( 0.0,  1.5) * texelSize;
    blurTexCoords[7] = texCoordVertex + vec2( 1.5,  1.5) * texelSize;
}
