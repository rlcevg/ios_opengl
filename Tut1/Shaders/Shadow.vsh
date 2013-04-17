#version 100

attribute vec4 positionVertex;
attribute vec3 normalVertex;
attribute vec4 colorVertex;
attribute vec2 texCoordVertex;

uniform mat4 modelViewProjectionMatrix;

void main()
{
	gl_Position = modelViewProjectionMatrix * positionVertex;
}
