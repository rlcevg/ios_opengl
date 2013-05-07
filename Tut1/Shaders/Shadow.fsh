#version 100
#extension GL_OES_standard_derivatives : enable
precision highp float;

varying float linearDepth;

void main()
{
    gl_FragColor = vec4(linearDepth);
}
