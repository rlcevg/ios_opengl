#version 100
precision highp float;

uniform sampler2D texSampler;
uniform float weights[7];

varying vec2 texCoord;
varying vec2 blurTexCoords0;
varying vec2 blurTexCoords1;
varying vec2 blurTexCoords2;
varying vec2 blurTexCoords3;
varying vec2 blurTexCoords4;
varying vec2 blurTexCoords5;
varying vec2 blurTexCoords6;
varying vec2 blurTexCoords7;
varying vec2 blurTexCoords8;
varying vec2 blurTexCoords9;
varying vec2 blurTexCoords10;
varying vec2 blurTexCoords11;

void main()
{
    vec4 color = vec4(0.0);

    color += texture2D(texSampler, blurTexCoords0 ) * weights[6];
    color += texture2D(texSampler, blurTexCoords1 ) * weights[5];
    color += texture2D(texSampler, blurTexCoords2 ) * weights[4];
    color += texture2D(texSampler, blurTexCoords3 ) * weights[3];
    color += texture2D(texSampler, blurTexCoords4 ) * weights[2];
    color += texture2D(texSampler, blurTexCoords5 ) * weights[1];
    color += texture2D(texSampler, texCoord       ) * weights[0];
    color += texture2D(texSampler, blurTexCoords6 ) * weights[1];
    color += texture2D(texSampler, blurTexCoords7 ) * weights[2];
    color += texture2D(texSampler, blurTexCoords8 ) * weights[3];
    color += texture2D(texSampler, blurTexCoords9 ) * weights[4];
    color += texture2D(texSampler, blurTexCoords10) * weights[5];
    color += texture2D(texSampler, blurTexCoords11) * weights[6];

	gl_FragColor = color;
}
