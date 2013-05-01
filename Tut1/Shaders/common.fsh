uniform vec2 texelSize;
varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec4 shadowCoord;

uniform sampler2DShadow shadowMap;

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

float lookup(vec2 offSet)
{
    // Values are multiplied by ShadowCoord.w because shadow2DProj does a W division for us.
	return shadow2DProjEXT(shadowMap, shadowCoord + vec4(offSet.x * texelSize.x * shadowCoord.w, offSet.y * texelSize.y * shadowCoord.w, 0.005, 0.0));
}

vec4 shadowedColor(void)
{
    // Do the shadow-map look-up
//    float shadow = shadow2DProjEXT(shadowMap, shadowCoord);
    float shadow = 1.0;
    if (shadowCoord.w > 1.0) {
        float x, y;
        for (y = -1.5; y <= 1.5; y += 1.0)
            for (x = -1.5; x <= 1.5; x += 1.0)
                shadow += lookup(vec2(x, y));
        shadow /= 16.0;
    }

    float shadowZ = shadowCoord.z / shadowCoord.w;
    // mapLinear(shadowZ, -1.0, 1.0)
    shadow = clamp(shadow + mapLinear(shadowZ, -10.0, 0.9), 0.1, 1.0);

    vec3 emissive = material.Ke;
    vec3 ambient = light.intensity * material.Ka;
    vec3 diffAndSpec = halfDiffuseSpecular(shadow);
    return vec4(diffAndSpec * shadow + ambient + emissive, 1.0) * color;
}
