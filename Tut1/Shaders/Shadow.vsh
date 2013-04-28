#version 100

attribute vec4 positionVertex;

uniform mat4 modelViewProjectionMatrix;

void main()
{
	gl_Position = modelViewProjectionMatrix * positionVertex;
}
