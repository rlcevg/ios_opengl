/////////////////////////////////////////////////
// 7x1 gaussian blur fragment shader
/////////////////////////////////////////////////
#version 100
precision highp float;

uniform bool direction;
uniform vec2 scale;
uniform sampler2D texSampler;

varying vec2 texCoord;

void main()
{
    vec4 color = vec4(0.0);
    color += texture2D(texSampler, texCoord + vec2(-5.5, -5.5) * scale) * 0.015625;
    color += texture2D(texSampler, texCoord + vec2(-3.5, -3.5) * scale) * 0.09375;
    color += texture2D(texSampler, texCoord + vec2(-1.5, -1.5) * scale) * 0.234375;
    color += texture2D(texSampler, texCoord) * 0.3125;
    color += texture2D(texSampler, texCoord + vec2(1.5, 1.5) * scale) * 0.234375;
    color += texture2D(texSampler, texCoord + vec2(3.5, 3.5) * scale) * 0.09375;
    color += texture2D(texSampler, texCoord + vec2(5.5, 5.5) * scale) * 0.015625;

//    color += texture2D(texSampler, texCoord + vec2(3.0, -3.0) * scale) * 0.015625;
//    color += texture2D(texSampler, texCoord + vec2(2.0, -2.0) * scale) * 0.09375;
//    color += texture2D(texSampler, texCoord + vec2(1.0, -1.0) * scale) * 0.234375;
//    color += texture2D(texSampler, texCoord) * 0.3125;
//    color += texture2D(texSampler, texCoord + vec2(1.0, 1.0) * scale) * 0.234375;
//    color += texture2D(texSampler, texCoord + vec2(2.0, 2.0) * scale) * 0.09375;
//    color += texture2D(texSampler, texCoord + vec2(3.0, 3.0) * scale) * 0.015625;

	gl_FragColor = color;
}
