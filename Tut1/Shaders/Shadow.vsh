#version 100

attribute vec4 positionVertex;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform float linearDepthConstant;  // 1.0 / (Far - Near)

varying float linearDepth;

void main()
{
    gl_Position = modelViewProjectionMatrix * positionVertex;
    linearDepth = length((modelViewMatrix * positionVertex).xyz) * linearDepthConstant;
}
