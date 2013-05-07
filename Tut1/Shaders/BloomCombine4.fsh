#version 100
precision highp float;

uniform sampler2D pass0;
uniform sampler2D pass1;
uniform sampler2D pass2;
uniform sampler2D pass3;
uniform sampler2D scene;

varying vec2 texCoord;

void main(void)
{
    gl_FragColor = texture2D(pass0, texCoord) +
                   texture2D(pass1, texCoord) +
                   texture2D(pass2, texCoord) +
                   texture2D(pass3, texCoord) +
                   texture2D(scene, texCoord);
}
