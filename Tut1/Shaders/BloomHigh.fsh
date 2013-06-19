#version 100
precision highp float;

uniform sampler2D texSampler;

varying vec2 texCoord;

void main()
{
    vec4 color = texture2D(texSampler, texCoord);

    color.x = color.x > 0.8 ? 1.0 : 0.0;
    color.y = color.y > 0.8 ? 1.0 : 0.0;
    color.z = color.z > 0.8 ? 1.0 : 0.0;

    gl_FragColor = color;
}
