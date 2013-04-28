//
//  Shader.vsh
//  Tut1
//
//  Created by Evgenij on 4/11/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#version 100

attribute vec4 positionVertex;
attribute vec3 normalVertex;
attribute vec4 colorVertex;
attribute vec2 texCoordVertex;

varying vec3 position;
varying vec3 normal;
varying vec4 color;
varying vec2 texCoord;
varying vec4 shadowCoord;

uniform mat4 modelviewMatrix;
uniform mat3 normalMatrix;
uniform mat4 shadowMatrix;
uniform mat4 modelViewProjectionMatrix;

void main()
{
    position = (modelviewMatrix * positionVertex).xyz;
    normal = normalize(normalMatrix * normalVertex);
    shadowCoord = shadowMatrix * positionVertex;
    color = colorVertex;
    texCoord = texCoordVertex;

    gl_Position = modelViewProjectionMatrix * positionVertex;
}
