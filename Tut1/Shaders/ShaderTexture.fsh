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

varying vec2 texCoord;

uniform sampler2D tex1;

// common.fsh
vec4 shadowedColor(void);

void main()
{
    gl_FragColor = shadowedColor() * texture2D(tex1, texCoord);
}
