#version 100
precision highp float;

uniform bool direction;
uniform float scale;
uniform sampler2D texSampler;

varying vec2 texCoord;

void main()
{
    vec4 color;
    if (direction) {
        color.x = texture2D(texSampler, texCoord + vec2(-1.5 * scale, 0.0 * scale)).r;
        color.y = texture2D(texSampler, texCoord + vec2(-0.5 * scale, 0.0)).r;
        color.z = texture2D(texSampler, texCoord + vec2(0.5 * scale, 0.0)).r;
        color.w = texture2D(texSampler, texCoord + vec2(1.5 * scale, 0.0)).r;
        color = vec4(dot(color, vec4(0.25)));
    } else {
        color.x = texture2D(texSampler, texCoord + vec2(0.0, -1.5 * scale)).r;
        color.y = texture2D(texSampler, texCoord + vec2(0.0, -0.5 * scale)).r;
        color.z = texture2D(texSampler, texCoord + vec2(0.0, 0.5 * scale)).r;
        color.w = texture2D(texSampler, texCoord + vec2(0.0, 1.5 * scale)).r;
        color = vec4(dot(color, vec4(0.25)));
    }

	gl_FragColor = color;
}
