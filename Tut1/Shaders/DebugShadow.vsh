#version 100

attribute vec4 positionVertex;
attribute vec2 texCoordVertex;

uniform mat4 modelViewProjectionMatrix;

varying vec2 texCoord;

void main()
{
    texCoord = texCoordVertex;
	gl_Position = modelViewProjectionMatrix * positionVertex;
}
