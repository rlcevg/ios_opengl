#version 100
precision highp float;

uniform sampler2D texSampler;
uniform float weights[6];

varying vec2 texCoord;
varying vec2 blurTexCoords[10];

void main()
{
    vec4 color = vec4(0.0);

    color += texture2D(texSampler, blurTexCoords[0]) * weights[5];
    color += texture2D(texSampler, blurTexCoords[1]) * weights[4];
    color += texture2D(texSampler, blurTexCoords[2]) * weights[3];
    color += texture2D(texSampler, blurTexCoords[3]) * weights[2];
    color += texture2D(texSampler, blurTexCoords[4]) * weights[1];
    color += texture2D(texSampler, texCoord        ) * weights[0];
    color += texture2D(texSampler, blurTexCoords[5]) * weights[1];
    color += texture2D(texSampler, blurTexCoords[6]) * weights[2];
    color += texture2D(texSampler, blurTexCoords[7]) * weights[3];
    color += texture2D(texSampler, blurTexCoords[8]) * weights[4];
    color += texture2D(texSampler, blurTexCoords[9]) * weights[5];

	gl_FragColor = color;
}
