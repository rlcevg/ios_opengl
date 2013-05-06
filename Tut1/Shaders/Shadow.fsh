#version 100
#extension GL_OES_standard_derivatives : enable
precision highp float;

varying float linearDepth;

// encoding: value = [0..1]
vec2 distributePrecision(float value)
{
    // 2048=2^11, 11-bit precision; 256 - 8-bit
    #define DISTRIBUTE_FACTOR (2048.0)
    #define FACTOR_INV (1.0 / DISTRIBUTE_FACTOR)

    float scaled_value = value * DISTRIBUTE_FACTOR;
    return vec2(floor(scaled_value) * FACTOR_INV, fract(scaled_value));
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
    #define ESM_K 4.0
//    float linearDepth = gl_FragCoord.z;
//    gl_FragColor = vec4(computeMoments(exp(ESM_K * linearDepth)), computeMoments(-exp(-ESM_K * linearDepth)));
//    vec2 moments = computeMoments(exp(g_ExpWarp_C * linearDepth));
//    gl_FragColor = vec4(computeMoments(linearDepth), exp(ESM_K * linearDepth), 0.0);
    gl_FragColor = vec4(computeMoments(linearDepth), linearDepth, 0.0);
//    gl_FragColor = vec4(computeMoments(linearDepth), exp(linearDepth), 0.0);
}
