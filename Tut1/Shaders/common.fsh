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
    if (shadow > 0.8 && df > 0.1) {
        return light.intensity * (material.Kd * df + material.Ks * pow(max(0.0, dot(h, normal)), material.shininess));
    } else {
        return light.intensity * material.Kd * df;
    }
}

float esmShadow(float occluder, float receiver)
{
    // Range [0, 80]
    #define ESM_K 8.0
    // Range [0, -oo]
    #define ESM_MIN	 -0.5
    // Range [1, 10]
    #define ESM_DIFFUSE_SCALE 1.79

    float shadow = clamp(exp(max(ESM_MIN, ESM_K * (occluder - receiver))), 0.0, 1.0);
    return 1.0 - (ESM_DIFFUSE_SCALE * (1.0 - shadow));
}

vec4 shadowedColor(void)
{
    float shadow = 1.0;
    // ensure that object is in front of light frustum/position
    if (shadowCoord.w > 0.0) {
        vec3 shadowCoordPostW = shadowCoord.xyz / shadowCoord.w;
        if ((shadowCoordPostW.x >= 0.0) && (shadowCoordPostW.x <= 1.0) &&
            (shadowCoordPostW.y >= 0.0) && (shadowCoordPostW.y <= 1.0))
        {
            float receiver = distance(position, light.position.xyz) * linearDepthConstant;
            vec4 data = texture2D(shadowMap, shadowCoordPostW.xy);
            shadow = esmShadow(data.r, receiver);
        }
    }

    vec3 emissive = material.Ke;
    vec3 ambient = light.intensity * material.Ka;
    vec3 diffAndSpec = halfDiffuseSpecular(shadow);
    return vec4(diffAndSpec * shadow + ambient + emissive, 1.0) * color;
}
