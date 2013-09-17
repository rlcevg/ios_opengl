#version 100
precision highp float;

uniform sampler2D texSampler;
uniform float weights[2];

varying vec2 texCoord;
varying vec2 blurTexCoords[2];

void main()
{
    vec4 color = vec4(0.0);

    color += texture2D(texSampler, blurTexCoords[0]) * weights[1];
    color += texture2D(texSampler, texCoord        ) * weights[0];
    color += texture2D(texSampler, blurTexCoords[1]) * weights[1];

	gl_FragColor = color;
}
