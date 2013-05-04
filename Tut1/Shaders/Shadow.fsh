#version 100
#extension GL_OES_standard_derivatives : enable
precision highp float;

varying float linearDepth;

// encoding: value = [0..1]
vec2 distributePrecision(float value)
{
    const float distributeFactor = 2048.0;  // 2048=2^11, 11-bit precision; 256 - 8-bit
    const float factorInv = 1.0 / distributeFactor;

    float scaled_value = value * distributeFactor;
    return vec2(floor(scaled_value) * factorInv, fract(scaled_value));
}

vec2 computeMoments(float depth)
{
//    float depth = v_position.z / v_position.w;
//    depth = depth * 0.5 + 0.5;  // move away from unit cube ([-1,1]) to [0,1] coordinate system

    float moment1 = depth;
    float moment2 = depth * depth;

    // Adjusting moments (this is sort of bias per pixel) using derivative
    float dx = dFdx(depth);
    float dy = dFdy(depth);
    moment2 += 0.25 * (dx * dx + dy * dy);

    return vec2(moment1, moment2);
}

void main()
{
    #define g_ExpWarp_C 2.0
    gl_FragColor = vec4(computeMoments(exp(g_ExpWarp_C * linearDepth)), computeMoments(-exp(-g_ExpWarp_C * linearDepth)));
}
