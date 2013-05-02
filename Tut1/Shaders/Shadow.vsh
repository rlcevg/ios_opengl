#version 100

attribute vec4 positionVertex;

uniform mat4 modelViewProjectionMatrix;

varying vec4 v_position;

void main()
{
    gl_Position = modelViewProjectionMatrix * positionVertex;
    v_position = gl_Position;
}
