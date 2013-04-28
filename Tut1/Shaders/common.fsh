vec3 halfDiffuseSpecular(float shadow)
{
    vec3 s = normalize(light.position.xyz - position.xyz);
    vec3 v = normalize(-position);
    vec3 h = normalize(v + s);
    if (shadow > 0.5) {
        return light.intensity * (material.Kd * max(0.0, dot(s, normal)) +
                                  material.Ks * pow(max(0.0, dot(h, normal)), material.shininess));
    } else {
        return light.intensity * material.Kd * max(0.0, dot(s, normal));
    }
}

float mapLinear(float fVal, float sMin, float sMax)
{
    return clamp(fVal * (sMax - sMin) + sMin, 0.0, 1.0);
}

vec4 shadowedColor(void)
{
    // Do the shadow-map look-up
    float shadow = shadow2DProjEXT(shadowMap, shadowCoord);
    float shadowZ = shadowCoord.z / shadowCoord.w;
    //    shadow = mapLinear(shadow + mapLinear(shadowZ, -1.0, 1.0), 0.1, 1.0);
    shadow = clamp(shadow + mapLinear(shadowZ, -10.0, 0.9), 0.1, 1.0);

    vec3 emissive = material.Ke;
    vec3 ambient = light.intensity * material.Ka;
    vec3 diffAndSpec = halfDiffuseSpecular(shadow);
    return vec4(diffAndSpec * shadow + ambient + emissive, 1.0);
}
