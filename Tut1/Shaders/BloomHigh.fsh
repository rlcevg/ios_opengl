#version 100
precision highp float;

uniform sampler2D texSampler;

varying vec2 texCoord;

void main()
{
    vec4 color = texture2D(texSampler, texCoord);

    color.r = color.r > 0.8 ? 1.0 : 0.0;
    color.g = color.g > 0.8 ? 1.0 : 0.0;
    color.b = color.b > 0.8 ? 1.0 : 0.0;

    gl_FragColor = color;
}
