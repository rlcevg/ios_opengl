/////////////////////////////////////////////////
// 9x1 gaussian blur fragment shader
/////////////////////////////////////////////////
#version 100
precision highp float;

uniform bool direction;
uniform float scale;
uniform sampler2D textureSource;
uniform float coefficients[9];

varying vec2 texCoord;

void main()
{
    vec4 color = vec4(0.0);
    if (direction) {
//        float x = -4.0;
//        for (int i = 0; i < 9; i++) {
//            color += texture2D(textureSource, vec2(texCoord.x + x * scale, 0.0)) * coefficients[i];
//            x += 1.0;
//        }
        color += texture2D(textureSource, texCoord + vec2(-3.0 * scale, 0.0)) * 0.015625;
        color += texture2D(textureSource, texCoord + vec2(-2.0 * scale, 0.0)) * 0.09375;
        color += texture2D(textureSource, texCoord + vec2(-1.0 * scale, 0.0)) * 0.234375;
        color += texture2D(textureSource, texCoord) * 0.3125;
        color += texture2D(textureSource, texCoord + vec2(1.0 * scale, 0.0)) * 0.234375;
        color += texture2D(textureSource, texCoord + vec2(2.0 * scale, 0.0)) * 0.09375;
        color += texture2D(textureSource, texCoord + vec2(3.0 * scale, 0.0)) * 0.015625;
    } else {
//        float y = -4.0;
//        for (int i = 0; i < 9; i++) {
//            color += texture2D(textureSource, vec2(0.0, texCoord.y + y * scale)) * coefficients[i];
//            y += 1.0;
//        }
        color += texture2D(textureSource, texCoord + vec2(0.0, -3.0 * scale)) * 0.015625;
        color += texture2D(textureSource, texCoord + vec2(0.0, -2.0 * scale)) * 0.09375;
        color += texture2D(textureSource, texCoord + vec2(0.0, -1.0 * scale)) * 0.234375;
        color += texture2D(textureSource, texCoord) * 0.3125;
        color += texture2D(textureSource, texCoord + vec2(0.0, 1.0 * scale)) * 0.234375;
        color += texture2D(textureSource, texCoord + vec2(0.0, 2.0 * scale)) * 0.09375;
        color += texture2D(textureSource, texCoord + vec2(0.0, 3.0 * scale)) * 0.015625;
    }
//	color += texture2D(textureSource, texCoord + vec2(-3.0 * scale.x, -3.0 * scale.y)) * 0.015625;
//	color += texture2D(textureSource, texCoord + vec2(-2.0 * scale.x, -2.0 * scale.y)) * 0.09375;
//	color += texture2D(textureSource, texCoord + vec2(-1.0 * scale.x, -1.0 * scale.y)) * 0.234375;
//	color += texture2D(textureSource, texCoord) * 0.3125;
//	color += texture2D(textureSource, texCoord + vec2(1.0 * scale.x, 1.0 * scale.y)) * 0.234375;
//	color += texture2D(textureSource, texCoord + vec2(2.0 * scale.x, 2.0 * scale.y)) * 0.09375;
//	color += texture2D(textureSource, texCoord + vec2(3.0 * scale.x, 3.0 * scale.y)) * 0.015625;

	gl_FragColor = color;
}
