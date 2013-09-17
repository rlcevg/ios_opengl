#version 100
precision highp float;

uniform sampler2D texSampler;

//varying vec2 texCoord;
varying vec2 blurTexCoords[8];

void main()
{
//    vec4 color;
//    color.x = texture2D(texSampler, blurTexCoords[0]).r;
//    color.y = texture2D(texSampler, blurTexCoords[1]).r;
//    color.z = texture2D(texSampler, blurTexCoords[2]).r;
//    color.w = texture2D(texSampler, blurTexCoords[3]).r;
//    gl_FragColor = vec4(dot(color, vec4(0.25)));

    vec4 sum1, sum2;
    sum1.x = texture2D(texSampler, blurTexCoords[0]).r;
    sum1.y = texture2D(texSampler, blurTexCoords[1]).r;
    sum1.z = texture2D(texSampler, blurTexCoords[2]).r;
    sum1.w = texture2D(texSampler, blurTexCoords[3]).r;
    sum2.x = texture2D(texSampler, blurTexCoords[4]).r;
    sum2.y = texture2D(texSampler, blurTexCoords[5]).r;
    sum2.z = texture2D(texSampler, blurTexCoords[6]).r;
    sum2.w = texture2D(texSampler, blurTexCoords[7]).r;
    gl_FragColor  = vec4(dot(sum1, vec4(1.0 / 8.0)));
    gl_FragColor += vec4(dot(sum2, vec4(1.0 / 8.0)));
//    gl_FragColor += vec4(texture2D(texSampler, texCoord).r / 9.0);
}
