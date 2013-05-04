varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec4 shadowCoord;

uniform vec2 texelSize;
uniform float linearDepthConstant;  // 1.0 / (Far - Near)
uniform sampler2D shadowMap;

struct LightInfo {
    vec4 position;
    vec3 intensity;
};
uniform LightInfo light;

struct MaterialInfo {
    vec3 Ke; // Emissive light
    vec3 Ka; // Ambient reflectivity
    vec3 Kd; // Diffuse reflectivity
    vec3 Ks; // Specular reflectivity
    float shininess; // Specular shininess factor
};
uniform MaterialInfo material;

vec3 halfDiffuseSpecular(float shadow)
{
    vec3 s = normalize(light.position.xyz - position.xyz);
    vec3 v = normalize(-position);
    vec3 h = normalize(v + s);
    float df = max(0.0, dot(s, normal));
    if (shadow > 0.9 && df > 0.1) {
        return light.intensity * (material.Kd * df + material.Ks * pow(max(0.0, dot(h, normal)), material.shininess));
    } else {
        return light.intensity * material.Kd * df;
    }
}

float mapLinear(float fVal, float sMin, float sMax)
{
    return clamp(fVal * (sMax - sMin) + sMin, 0.0, 1.0);
}

float reduceLightBleeding(float p_t, float aggressiveness)
{
    return max(0.0, (p_t - aggressiveness) / (1.0 - aggressiveness));
}

float chebyshevUpperBound(vec2 moments, float t, float minVariance)
{
    // Surface is fully lit. as the current fragment is before the light occluder
    if (t <= moments.x)
        return 1.0;

    // The fragment is either in shadow or penumbra. We now use chebyshev's upperBound to check
    // How likely this pixel is to be lit (p_max)
    float variance = moments.y - (moments.x * moments.x);
    variance = max(variance, 0.00002);

    float d = t - moments.x;
    float p_max = variance / (variance + d * d);

    return p_max;
//    return reduceLightBleeding(p_max, 0.7);
}

//float lookup(vec2 offset)
//{
//    // Values are multiplied by ShadowCoord.w because shadow2DProj does a W division for us.
//	return shadow2DProjEXT(shadowMap, shadowCoord + vec4(offset.x * texelSize.x * shadowCoord.w, offset.y * texelSize.y * shadowCoord.w, 0.005, 0.0));
//}

float recombinePrecision(vec2 value)
{
    const float distributeFactor = 2048.0;  // see Shadow.fsh
    const float factorInv = 1.0 / distributeFactor;
    return dot(value, vec2(1.0, factorInv));
}

float esmShadow(vec2 offset)
{
    // Range [0, 80]
    #define ESM_K 4.0
    // Range [0, -oo]
    #define ESM_MIN	 -0.5
    // Range [1, 10]
    #define ESM_DIFFUSE_SCALE 1.79

    float receiver = distance(position, light.position.xyz) * linearDepthConstant;
//    float occluder = recombinePrecision(texture2D(shadowMap, offset).rg);
    float occluder = texture2D(shadowMap, offset).r;
    float shadow = clamp(exp(max(ESM_MIN, ESM_K * (occluder - receiver))), 0.0, 1.0);
    return 1.0 - (ESM_DIFFUSE_SCALE * (1.0 - shadow));
//    float shadow = pow(occluder * exp(1.0), ESM_K) / exp(ESM_K * receiver);
//    float shadow = clamp(pow(occluder, ESM_K) / exp(ESM_K * receiver), 0.0, 1.0);
//    return shadow;
}

float evsmShadow(vec2 offset)
{
    #define g_ExpWarp_C 2.0
    #define g_VSMMinVariance 0.002
    float depth = 2.0 * distance(position, light.position.xyz) * linearDepthConstant - 1.0;

    float posDepth =  exp( g_ExpWarp_C * depth);
    float negDepth = -exp(-g_ExpWarp_C * depth);

    vec4 data = texture2D(shadowMap, offset);
    vec2 posMoments = data.xy;
    vec2 negMoments = data.zw;

    // derivative of warping at Depth
    // TODO: Make this faster and less awkward/redundant...
    float posDepthScale = g_ExpWarp_C * posDepth;
//    float posDepthScale = posDepth;
    float posMinVariance = g_VSMMinVariance * (posDepthScale * posDepthScale);
    float posShadowContrib = chebyshevUpperBound(posMoments, posDepth, posMinVariance);

    float negDepthScale = g_ExpWarp_C * negDepth;
//    float negDepthScale = negDepth;
    float negMinVariance = g_VSMMinVariance * (negDepthScale * negDepthScale);
    float negShadowContrib = chebyshevUpperBound(negMoments, negDepth, negMinVariance);

    //float shadowContrib = posShadowContrib;
    //float shadowContrib = negShadowContrib;
    float shadowContrib = min(posShadowContrib, negShadowContrib);
    //float shadowContrib = sqrt(posShadowContrib * negShadowContrib);

    return shadowContrib;
}

vec4 shadowedColor(void)
{
    // Do the shadow-map look-up
//    float shadow = shadow2DProjEXT(shadowMap, shadowCoord);
//    float shadow = 1.0;
//    if (shadowCoord.w > 1.0) {
//        float x, y;
//        for (y = -1.5; y <= 1.5; y += 1.0)
//            for (x = -1.5; x <= 1.5; x += 1.0)
//                shadow += lookup(vec2(x, y));
//        shadow /= 16.0;
//    }

//    float shadow = 1.0;
//    if (shadowCoord.w > 0.0) {
//        vec4 shadowCoordPostW = shadowCoord / shadowCoord.w;
//        if ((shadowCoordPostW.x >= 0.0) && (shadowCoordPostW.x <= 1.0) &&
//            (shadowCoordPostW.y >= 0.0) && (shadowCoordPostW.y <= 1.0)) {
//            shadow = chebyshevUpperBound(shadowCoordPostW.z, shadowCoordPostW.xy);
//            shadow = clamp(shadow + mapLinear(shadowCoordPostW.z, -20.0, 0.9), 0.1, 1.0);
//        }
//    }

    float shadow = 1.0;
    if (shadowCoord.w > 0.0) {
        vec3 shadowCoordPostW = shadowCoord.xyz / shadowCoord.w;
        if ((shadowCoordPostW.x >= 0.0) && (shadowCoordPostW.x <= 1.0) &&
            (shadowCoordPostW.y >= 0.0) && (shadowCoordPostW.y <= 1.0)) {
            shadow = evsmShadow(shadowCoordPostW.xy);
//            shadow = clamp(shadow + mapLinear(shadowCoordPostW.z, -10.0, 0.9), 0.1, 1.0);
//            shadow = clamp(shadow + mapLinear(shadowCoordPostW.z, -20.0, 0.9), 0.1, 1.0);
        }
    }

    vec3 emissive = material.Ke;
    vec3 ambient = light.intensity * material.Ka;
    vec3 diffAndSpec = halfDiffuseSpecular(shadow);
    return vec4(diffAndSpec * shadow + ambient + emissive, 1.0) * color;
}
