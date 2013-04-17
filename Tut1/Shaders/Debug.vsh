#version 100

attribute vec4 positionVertex;
attribute vec3 normalVertex;
attribute vec4 colorVertex;
attribute vec2 texCoordVertex;

uniform mat4 modelViewProjectionMatrix;

varying vec2 texCoord;

void main()
{
    texCoord = texCoordVertex;
	gl_Position = modelViewProjectionMatrix * positionVertex;
}
