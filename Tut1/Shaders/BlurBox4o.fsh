#version 100
precision highp float;

uniform bool direction;
uniform float scale;
uniform sampler2D textureSource;

varying vec2 texCoord;

void main()
{
    vec4 color;
    if (direction) {
        color = texture2D(textureSource, texCoord + vec2(-1.5 * scale, 0.0));
        color += texture2D(textureSource, texCoord + vec2(-0.5 * scale, 0.0));
        color += texture2D(textureSource, texCoord + vec2(0.5 * scale, 0.0));
        color += texture2D(textureSource, texCoord + vec2(1.5 * scale, 0.0));
        color *= 0.25;
    } else {
        color = texture2D(textureSource, texCoord + vec2(0.0, -1.5 * scale));
        color += texture2D(textureSource, texCoord + vec2(0.0, -0.5 * scale));
        color += texture2D(textureSource, texCoord + vec2(0.0, 0.5 * scale));
        color += texture2D(textureSource, texCoord + vec2(0.0, 1.5 * scale));
        color *= 0.25;
    }

	gl_FragColor = color;
}
