varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec4 shadowCoord;

uniform bool b_sh;
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

//float lookup(vec2 offset)
//{
//    // Values are multiplied by ShadowCoord.w because shadow2DProj does a W division for us.
//	return shadow2DProjEXT(shadowMap, shadowCoord + vec4(offset.x * texelSize.x * shadowCoord.w, offset.y * texelSize.y * shadowCoord.w, 0.005, 0.0));
//}

float recombinePrecision(vec2 value)
{
    // see Shadow.fsh
    #define DISTRIBUTE_FACTOR (2048.0)
    #define FACTOR_INV (1.0 / DISTRIBUTE_FACTOR)

    return dot(value, vec2(1.0, FACTOR_INV));
}

float chebyshevUpperBound(vec2 moments, float t)
{
    #define VSM_MIN_VARIANCE 0.00002

    // Surface is fully lit. as the current fragment is before the light occluder
    if (t <= moments.x)
        return 1.0;

    // The fragment is either in shadow or penumbra. We now use chebyshev's upperBound to check
    // How likely this pixel is to be lit (p_max)
    float variance = moments.y - (moments.x * moments.x);
    variance = max(variance, VSM_MIN_VARIANCE);

    float d = t - moments.x;
    float p_max = variance / (variance + d * d);

    return p_max;
//    return reduceLightBleeding(p_max, 0.7);
}

float vsmShadow(vec2 moments, float receiver)
{
    return chebyshevUpperBound(moments, receiver);
}

float esmShadow(float occluder, float receiver)
{
    // Range [0, 80]
    #define ESM_K 10.0
    // Range [0, -oo]
    #define ESM_MIN	 -0.5
    // Range [1, 10]
    #define ESM_DIFFUSE_SCALE 1.79

    float shadow = clamp(exp(max(ESM_MIN, ESM_K * (occluder - receiver))), 0.0, 1.0);
    return 1.0 - (ESM_DIFFUSE_SCALE * (1.0 - shadow));
//    float shadow = pow(occluder * exp(1.0), ESM_K) / exp(ESM_K * receiver);
//    float shadow = clamp(pow(occluder, ESM_K) / exp(ESM_K * receiver), 0.0, 1.0);
//    return shadow;
//    return occluder / exp(ESM_K * receiver);
//    return exp(ESM_K * (occluder - receiver));
//    return clamp(exp(ESM_K * (occluder - receiver)), 0.0, 1.0);
//    return pow(occluder, ESM_K) / exp(ESM_K * receiver);
}

//float evsmShadow(vec4 data, float receiver)
//{
//    #define EXP_WARP_C 4.0
//    #define VSM_MIN_VARIANCE 0.00002
//
//    float posDepth =  exp( EXP_WARP_C * receiver);
//    float negDepth = -exp(-EXP_WARP_C * receiver);
//
//    vec2 posMoments = data.xy;
//    vec2 negMoments = data.zw;
//
//    // derivative of warping at Depth
//    // TODO: Make this faster and less awkward/redundant...
//    float posDepthScale = EXP_WARP_C * posDepth;
//    float posMinVariance = VSM_MIN_VARIANCE * (posDepthScale * posDepthScale);
//    float posShadowContrib = chebyshevUpperBound(posMoments, posDepth, posMinVariance);
//
//    float negDepthScale = EXP_WARP_C * negDepth;
//    float negMinVariance = VSM_MIN_VARIANCE * (negDepthScale * negDepthScale);
//    float negShadowContrib = chebyshevUpperBound(negMoments, negDepth, negMinVariance);
//
//    return min(posShadowContrib, negShadowContrib);
//}

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
    // ensure that object is in front of light frustum/position
    if (shadowCoord.w > 0.0) {
        vec3 shadowCoordPostW = shadowCoord.xyz / shadowCoord.w;
        if ((shadowCoordPostW.x >= 0.0) && (shadowCoordPostW.x <= 1.0) &&
            (shadowCoordPostW.y >= 0.0) && (shadowCoordPostW.y <= 1.0))
        {
//            float receiver = 2.0 * distance(position, light.position.xyz) * linearDepthConstant - 1.0;
            float receiver = distance(position, light.position.xyz) * linearDepthConstant;
            vec4 data = texture2D(shadowMap, shadowCoordPostW.xy);
//            shadow = b_sh ? vsmShadow(data.xy, receiver) : esmShadow(data.z, receiver);
//            shadow = evsmShadow(data, receiver);
            shadow = vsmShadow(data.xy, receiver) * esmShadow(data.z, receiver);
//            shadow = max(vsmShadow(data.xy, receiver), esmShadow(data.z, receiver));
//            shadow = clamp(shadow + mapLinear(shadowCoordPostW.z, -10.0, 0.9), 0.1, 1.0);
//            shadow = clamp(shadow + mapLinear(shadowCoordPostW.z, -20.0, 0.9), 0.1, 1.0);
        }
    }

    vec3 emissive = material.Ke;
    vec3 ambient = light.intensity * material.Ka;
    vec3 diffAndSpec = halfDiffuseSpecular(shadow);
    return vec4(diffAndSpec * shadow + ambient + emissive, 1.0) * color;
}
