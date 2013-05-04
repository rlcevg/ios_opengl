#version 100

attribute vec4 positionVertex;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;

varying vec4 v_position;

void main()
{
    gl_Position = modelViewProjectionMatrix * positionVertex;
    v_position = modelViewMatrix * positionVertex;
}
