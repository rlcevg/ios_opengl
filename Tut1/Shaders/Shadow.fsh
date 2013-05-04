#version 100
precision highp float;

uniform float linearDepthConstant;  // 1.0 / (Far - Near)

varying vec4 v_position;

// encoding: value = [0..1]
vec2 distributePrecision(float value)
{
    const float distributeFactor = 2048.0;  // 2048=2^11, 11-bit precision; 256 - 8-bit
    const float factorInv = 1.0 / distributeFactor;

    float scaled_value = value * distributeFactor;
    return vec2(floor(scaled_value) * factorInv, fract(scaled_value));
}

void main()
{
    float linearDepth = length(v_position) * linearDepthConstant;
//    gl_FragColor = vec4(distributePrecision(linearDepth), 0.0, 0.0);
    gl_FragColor = vec4(linearDepth);
//    gl_FragColor = vec4(distributePrecision(exp(linearDepth) / exp(1.0)), 0.0, 0.0);
//    gl_FragColor = vec4(exp(linearDepth));
}
