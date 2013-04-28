//
//  Shader.fsh
//  Tut1
//
//  Created by Evgenij on 4/11/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#version 100
#extension GL_EXT_shadow_samplers : require
precision highp float;

varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec2 texCoord;
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

vec3 phongHalfModelDiffAndSpec()
{
    vec3 s = normalize(light.position.xyz - position.xyz);
    vec3 v = normalize(-position);
    vec3 h = normalize(v + s);
    return light.intensity * (material.Kd * max(0.0, dot(s, normal)) +
            material.Ks * pow(max(0.0, dot(h, normal)), material.shininess));
}

float mapLinear(float fVal, float sMin, float sMax)
{
    return clamp(fVal * (sMax - sMin) + sMin, 0.0, 1.0);
}

void main()
{
    vec3 emissive = material.Ke;
    vec3 ambient = light.intensity * material.Ka;
    vec3 diffAndSpec = phongHalfModelDiffAndSpec();

    // Do the shadow-map look-up
    float shadow = shadow2DProjEXT(shadowMap, shadowCoord);

    float shadowZ = shadowCoord.z / shadowCoord.w;
//    shadow = mapLinear(shadow + mapLinear(shadowZ, -1.0, 1.0), 0.1, 1.0);
    shadow = clamp(shadow + mapLinear(shadowZ, -10.0, 0.9), 0.1, 1.0);

    // If the fragment is in shadow, use ambient light only.
    gl_FragColor = vec4(diffAndSpec * shadow + ambient + emissive, 1.0) * color;
}
