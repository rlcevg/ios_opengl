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

// common.fsh
vec4 shadowedColor(void);

void main()
{
    gl_FragColor = shadowedColor() * color;
}
