#version 100
precision highp float;

varying vec2 texCoord;

uniform sampler2D texSampler;  // 0

void main()
{
    gl_FragColor = texture2D(texSampler, texCoord);
}
