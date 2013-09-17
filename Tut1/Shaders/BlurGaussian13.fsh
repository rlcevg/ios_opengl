#version 100
precision highp float;

uniform sampler2D texSampler;
uniform float weights[4];

varying vec2 texCoord;
varying vec2 blurTexCoords[6];

void main()
{
    vec4 color = vec4(0.0);

    color += texture2D(texSampler, blurTexCoords[0]) * weights[3];
    color += texture2D(texSampler, blurTexCoords[1]) * weights[2];
    color += texture2D(texSampler, blurTexCoords[2]) * weights[1];
    color += texture2D(texSampler, texCoord        ) * weights[0];
    color += texture2D(texSampler, blurTexCoords[3]) * weights[1];
    color += texture2D(texSampler, blurTexCoords[4]) * weights[2];
    color += texture2D(texSampler, blurTexCoords[5]) * weights[3];

	gl_FragColor = color;
}
