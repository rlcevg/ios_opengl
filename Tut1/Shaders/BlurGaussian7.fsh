/////////////////////////////////////////////////
// 7x1 gaussian blur fragment shader
/////////////////////////////////////////////////
#version 100
precision highp float;

uniform bool direction;
uniform float scale;
uniform sampler2D textureSource;

varying vec2 texCoord;

void main()
{
    vec4 color = vec4(0.0);
    if (direction) {
        color += texture2D(textureSource, vec2(texCoord.x + -3.0 * scale, texCoord.y)) * 0.015625;
        color += texture2D(textureSource, vec2(texCoord.x + -2.0 * scale, texCoord.y)) * 0.09375;
        color += texture2D(textureSource, vec2(texCoord.x + -1.0 * scale, texCoord.y)) * 0.234375;
        color += texture2D(textureSource, texCoord) * 0.3125;
        color += texture2D(textureSource, vec2(texCoord.x + 1.0 * scale, texCoord.y)) * 0.234375;
        color += texture2D(textureSource, vec2(texCoord.x + 2.0 * scale, texCoord.y)) * 0.09375;
        color += texture2D(textureSource, vec2(texCoord.x + 3.0 * scale, texCoord.y)) * 0.015625;
    } else {
        color += texture2D(textureSource, vec2(texCoord.x, texCoord.y + -3.0 * scale)) * 0.015625;
        color += texture2D(textureSource, vec2(texCoord.x, texCoord.y + -2.0 * scale)) * 0.09375;
        color += texture2D(textureSource, vec2(texCoord.x, texCoord.y + -1.0 * scale)) * 0.234375;
        color += texture2D(textureSource, texCoord) * 0.3125;
        color += texture2D(textureSource, vec2(texCoord.x, texCoord.y + 1.0 * scale)) * 0.234375;
        color += texture2D(textureSource, vec2(texCoord.x, texCoord.y + 2.0 * scale)) * 0.09375;
        color += texture2D(textureSource, vec2(texCoord.x, texCoord.y + 3.0 * scale)) * 0.015625;
    }

	gl_FragColor = color;
}
