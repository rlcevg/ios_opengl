#version 100
precision highp float;

uniform sampler2D texSampler;
uniform float weights[5];

varying vec2 texCoord;
varying vec2 blurTexCoords[8];

void main()
{
    vec4 color = vec4(0.0);

    color += texture2D(texSampler, blurTexCoords[0]) * weights[4];
    color += texture2D(texSampler, blurTexCoords[1]) * weights[3];
    color += texture2D(texSampler, blurTexCoords[2]) * weights[2];
    color += texture2D(texSampler, blurTexCoords[3]) * weights[1];
    color += texture2D(texSampler, texCoord        ) * weights[0];
    color += texture2D(texSampler, blurTexCoords[4]) * weights[1];
    color += texture2D(texSampler, blurTexCoords[5]) * weights[2];
    color += texture2D(texSampler, blurTexCoords[6]) * weights[3];
    color += texture2D(texSampler, blurTexCoords[7]) * weights[4];

	gl_FragColor = color;
}
