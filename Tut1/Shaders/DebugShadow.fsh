#version 100
precision highp float;

varying vec2 texCoord;

uniform sampler2D depthSampler; // 0

float linearizeDepth(vec2 uv)
{
    float n = 1.0; // camera z near
    float f = 100.0; // camera z far
    float z = texture2D(depthSampler, uv).r;
    return (2.0 * n) / (f + n - z * (f - n));
}

void main()
{
    float d = linearizeDepth(texCoord);
    gl_FragColor = vec4(d, d, d, 1.0);
}
