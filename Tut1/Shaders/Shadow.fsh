#version 100
#extension GL_OES_standard_derivatives : enable
precision highp float;

varying float linearDepth;

// encoding: value = [0..1]
vec4 distributePrecision(vec2 value)
{
    // 2048=2^11, 11-bit precision; 256 - 8-bit
    #define DISTRIBUTE_FACTOR (2048.0)
    #define FACTOR_INV (1.0 / DISTRIBUTE_FACTOR)

    vec2 scaled_value = value * DISTRIBUTE_FACTOR;
    return vec4(floor(scaled_value) * FACTOR_INV, fract(scaled_value));
}

vec2 computeMoments(float depth)
{
    float moment2 = depth * depth;

    // Adjusting moments (this is sort of bias per pixel) using derivative
    vec2 dxdy = vec2(dFdx(depth), dFdy(depth));
    // moment2 += 0.25 * (dx * dx + dy * dy);
    moment2 += 0.25 * dot(dxdy, dxdy);

    return vec2(depth, moment2);
}

void main()
{
    #define g_ExpWarp_C 5.0
//    gl_FragColor = vec4(computeMoments(exp(g_ExpWarp_C * linearDepth)), computeMoments(-exp(-g_ExpWarp_C * linearDepth)));
    vec2 moments = computeMoments(exp(g_ExpWarp_C * linearDepth));
    gl_FragColor = distributePrecision(moments);
}
