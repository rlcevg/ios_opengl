#version 100
precision highp float;

uniform sampler2D texSampler;

varying vec2 texCoord;

void main()
{
//    #define BRIGHT_PASS_THRESHOLD vec3(0.8, 0.8, 0.8)

    vec4 color = texture2D(texSampler, texCoord);

//    color.xyz -= BRIGHT_PASS_THRESHOLD;
//    color.xyz = clamp(color.xyz, 0.0, 0.2) * 10.0;

    color.x = color.x > 0.8 ? 1.0 : 0.0;
    color.y = color.y > 0.8 ? 1.0 : 0.0;
    color.z = color.z > 0.8 ? 1.0 : 0.0;

    gl_FragColor = color;
}
