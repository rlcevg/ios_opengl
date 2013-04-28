//
//  SceneEffect.m
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "SceneEffect.h"
#import "GLSLProgram.h"
#import "Drawable.h"
#import "Light.h"
#import "Camera.h"
#import "FBOShadow.h"

#pragma mark

@interface SceneEffect ()

@property (strong, nonatomic) GLSLProgram *program;

@end

#pragma mark

@implementation SceneEffect

@synthesize program = _program;

- (id)init
{
    if (self = [super init]) {
        _program = nil;
        _light = nil;
        _camera = nil;
    }
    return self;
}

- (void)dealloc
{
    self.program = nil;
}

- (GLSLProgram *)program
{
    if (!_program) {
        _program = [GLSLProgram new];
        NSDictionary *attr = @{
            [NSNumber numberWithInteger:GLKVertexAttribPosition] : @"positionVertex",
            [NSNumber numberWithInteger:GLKVertexAttribNormal] : @"normalVertex",
            [NSNumber numberWithInteger:GLKVertexAttribColor] : @"colorVertex",
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        if (![_program loadShaders:@"Shader" withAttr:attr]) {
            [_program printLog];
        }
    }
    return _program;
}

- (void)prepareToDraw:(id<Drawable>)object
{
    GLSLProgram *program = self.program;
    [program use];

    MaterialInfo material = [object material];
    [program setUniform:"material.Ke" vec3:material.Ke];
    [program setUniform:"material.Ka" vec3:material.Ka];
    [program setUniform:"material.Kd" vec3:material.Kd];
    [program setUniform:"material.Ks" vec3:material.Ks];
    [program setUniform:"material.shininess" valFloat:material.shininess];

    if (self.light) {
        if (self.camera) {
            [program setUniform:"light.position"
                           vec4:GLKMatrix4MultiplyVector4(self.camera.viewMatrix,
                                                          self.light.position)];
        }
        [program setUniform:"light.intensity" vec3:self.light.intensity];
        GLKMatrix4 lightViewProjectionMatrix = GLKMatrix4Multiply(GLKMatrix4Multiply(
                    [FBOShadow shadowBias], self.light.projectionMatrix),
                    self.light.viewMatrix);
        [program setUniform:"shadowMatrix" mat4:GLKMatrix4Multiply(lightViewProjectionMatrix, object.modelMatrix)];
    }

    if (self.camera) {
        GLKMatrix4 modelviewMatrix = GLKMatrix4Multiply(self.camera.viewMatrix, object.modelMatrix);
        [program setUniform:"modelviewMatrix" mat4:modelviewMatrix];
        GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelviewMatrix), NULL);
        [program setUniform:"normalMatrix" mat3:normalMatrix];
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.camera.projectionMatrix, modelviewMatrix);
        [program setUniform:"modelViewProjectionMatrix" mat4:modelViewProjectionMatrix];
    }

    [program setUniform:"shadowMap" valInt:0];

    if ([object respondsToSelector:@selector(constantColor)]) {
        GLKVector3 color = [object constantColor];
        glVertexAttrib3fv(GLKVertexAttribColor, (const GLfloat *)&color);
    }
}

@end
