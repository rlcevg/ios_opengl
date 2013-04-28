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

@interface SceneEffect () {
    GLKVector4 _lightPosition;
    GLKMatrix4 _lightViewProjectionMatrix;
}
@property (strong, nonatomic) GLSLProgram *program;
@property (strong, nonatomic) GLSLProgram *programTexture;

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
        };
        if (![_program loadShaders:@"Shader" withAttr:attr]) {
            [_program printLog];
        }
    }
    return _program;
}

- (GLSLProgram *)programTexture
{
    if (!_programTexture) {
        _programTexture = [GLSLProgram new];
        NSDictionary *attr = @{
            [NSNumber numberWithInteger:GLKVertexAttribPosition] : @"positionVertex",
            [NSNumber numberWithInteger:GLKVertexAttribNormal] : @"normalVertex",
            [NSNumber numberWithInteger:GLKVertexAttribColor] : @"colorVertex",
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        if (![_programTexture loadShaders:@"ShaderTexture" withAttr:attr]) {
            [_programTexture printLog];
        }
    }
    return _programTexture;
}

- (void)prepareToDraw
{
    _lightPosition = GLKMatrix4MultiplyVector4(self.camera.viewMatrix, self.light.position);
    _lightViewProjectionMatrix = GLKMatrix4Multiply(
        GLKMatrix4Multiply(
            [FBOShadow shadowBias],
            self.light.projectionMatrix
        ),
        self.light.viewMatrix
    );
}

- (void)prepareToDraw:(id<Drawable>)object
{
    GLSLProgram *program = nil;
    BOOL respondsToTexture = [object respondsToSelector:@selector(texture)];
    if (respondsToTexture)
        program = self.programTexture;
    else
        program = self.program;
    [program use];

    MaterialInfo material = [object material];
    [program setUniform:"material.Ke" vec3:material.Ke];
    [program setUniform:"material.Ka" vec3:material.Ka];
    [program setUniform:"material.Kd" vec3:material.Kd];
    [program setUniform:"material.Ks" vec3:material.Ks];
    [program setUniform:"material.shininess" valFloat:material.shininess];

    if (self.light) {
        if (self.camera) {
            [program setUniform:"light.position" vec4:_lightPosition];
        }
        [program setUniform:"light.intensity" vec3:self.light.intensity];
        [program setUniform:"shadowMatrix" mat4:GLKMatrix4Multiply(_lightViewProjectionMatrix, object.modelMatrix)];

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(self.light.shadow.target, self.light.shadow.name);
        [program setUniform:"shadowMap" valInt:0];
    }

    if (self.camera) {
        GLKMatrix4 modelviewMatrix = GLKMatrix4Multiply(self.camera.viewMatrix, object.modelMatrix);
        [program setUniform:"modelviewMatrix" mat4:modelviewMatrix];
        GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelviewMatrix), NULL);
        [program setUniform:"normalMatrix" mat3:normalMatrix];
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.camera.projectionMatrix, modelviewMatrix);
        [program setUniform:"modelViewProjectionMatrix" mat4:modelViewProjectionMatrix];
    }

    if ([object respondsToSelector:@selector(constantColor)]) {
        GLKVector3 color = [object constantColor];
        glVertexAttrib3fv(GLKVertexAttribColor, (const GLfloat *)&color);
    }

    if (respondsToTexture) {
        GLKTextureInfo *tex = [object texture];
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(tex.target, tex.name);
        [program setUniform:"tex1" valInt:1];
    }
}

@end
