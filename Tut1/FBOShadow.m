//
//  FBOShadow.m
//  Tut1
//
//  Created by Evgenij on 4/16/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "FBOShadow.h"
#import "GLSLProgram.h"
#import "Light.h"
#import "VBOScreenQuad.h"

#define DEPTH_DATA_TEX0 0
#define DEPTH_DATA_TEX1 1
#define SHADOW_FBO 0
#define BLUR_FBO 1
#define BLUR_COEF 1

#pragma mark

@interface FBOShadow () {
    GLuint _fbos[2];
    GLuint _rboDepth;
    GLuint _textures[2];
}
@property (strong, nonatomic) GLSLProgram *program;
@property (strong, nonatomic) GLSLProgram *programBlur;
@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;
@property (strong, nonatomic) VBOScreenQuad *quad;

@end

#pragma mark

@implementation FBOShadow

@synthesize program = _program;

- (id)init
{
    return [self initWithWidth:512 andHeight:512];
}

- (id)initWithWidth:(GLsizei)width andHeight:(GLsizei)height
{
    if (self = [super init]) {
        _quad = [VBOScreenQuad new];
        _program = nil;
        _programBlur = nil;
        _width = width;
        _height = height;
        _light = nil;
        _target = GL_TEXTURE_2D;

        glGenTextures(2, _textures);
        glGenFramebuffers(2, _fbos);

        // Create depth renderbuffer
        glGenRenderbuffers(1, &_rboDepth);
        glBindRenderbuffer(GL_RENDERBUFFER, _rboDepth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, width, height);

        // Create moment1-moment2 texture
        glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX0]);

        GLfloat fLargest;
        glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &fLargest);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, fLargest);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_HALF_FLOAT_OES, NULL);

        // Create and set up the depth FBO
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[SHADOW_FBO]);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rboDepth);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX0], 0);

        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Depth framebuffer is not complete: %x", fboStatus);
            return nil;
        }

        // Create blur color texture
        glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX1]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width >> BLUR_COEF, height >> BLUR_COEF, 0, GL_RGBA, GL_HALF_FLOAT_OES, 0);

        // Creating the blur FBO
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[BLUR_FBO]);

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX1], 0);

        fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Blur framebuffer is not complete: %x", fboStatus);
            return nil;
        }
        glBindTexture(GL_TEXTURE_2D, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    return self;
}

- (void)dealloc
{
    self.program = nil;
    self.programBlur = nil;
    self.quad = nil;

    glDeleteFramebuffers(2, _fbos);
	glDeleteTextures(2, _textures);
    glDeleteRenderbuffers(1, &_rboDepth);
}

- (GLSLProgram *)program
{
    if (!_program) {
        _program = [GLSLProgram new];
        NSDictionary *attrs = @{
            [NSNumber numberWithInteger:GLKVertexAttribPosition] : @"positionVertex",
        };
        if (![_program loadShaders:@"Shadow" withAttrs:attrs]) {
            [_program printLog];
        }
    }
    return _program;
}

- (GLSLProgram *)programBlur
{
    if (!_programBlur) {
        _programBlur = [GLSLProgram new];
        NSDictionary *attrs = @{
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        if (![_programBlur loadShaders:@"BlurBox4o" withAttrs:attrs]) {
            [_programBlur printLog];
        }
    }
    return _programBlur;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        if (enabled) {
            glBindFramebuffer(GL_FRAMEBUFFER, _fbos[SHADOW_FBO]);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glViewport(0, 0, _width, _height);
//            glCullFace(GL_FRONT);
//            glEnable(GL_POLYGON_OFFSET_FILL);
        } else {
//            glDisable(GL_POLYGON_OFFSET_FILL);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
        }
        _enabled = enabled;
    }
}

- (GLuint)name
{
    return _textures[DEPTH_DATA_TEX0];
}

- (GLKVector2)texelSize
{
    return GLKVector2Make(1.0 / self.width, 1.0 / self.height);
}

- (void)prepareToDraw:(id<Drawable>)object
{
    GLSLProgram *program = self.program;
    [program use];

    if (self.light) {
        GLKMatrix4 modelviewMatrix = GLKMatrix4Multiply(self.light.viewMatrix, object.modelMatrix);
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.light.projectionMatrix, modelviewMatrix);
        [program setUniform:"modelViewProjectionMatrix" mat4:modelViewProjectionMatrix];

        [program setUniform:"linearDepthConstant" valFloat:1.0 / (self.light.farZ - self.light.nearZ)];
        [program setUniform:"modelViewMatrix" mat4:modelviewMatrix];
    }
}

- (void)blur
{
    GLSLProgram *program = self.programBlur;
    [program use];

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX0]);
    glGenerateMipmap(GL_TEXTURE_2D);
    glDisable(GL_DEPTH_TEST);
//    glCullFace(GL_BACK);
    [program setUniform:"textureSource" valInt:0];

    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[BLUR_FBO]);
    glViewport(0, 0, _width >> BLUR_COEF, _height >> BLUR_COEF);
    [program setUniform:"direction" valBool:YES];
    [program setUniform:"scale" valFloat:1.0 / (_width >> BLUR_COEF)];
    [self.quad render];

    glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX1]);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[SHADOW_FBO]);
    glViewport(0, 0, _width, _height);
    [program setUniform:"direction" valBool:NO];
    [program setUniform:"scale" valFloat:1.0 / _height];
    [self.quad render];

    glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX0]);
    glGenerateMipmap(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
}

+ (GLKMatrix4)shadowBias
{
    return GLKMatrix4Make(0.5f, 0.0f, 0.0f, 0.0f,
                          0.0f, 0.5f, 0.0f, 0.0f,
                          0.0f, 0.0f, 0.5f, 0.0f,
                          0.5f, 0.5f, 0.5f, 1.0f);
}

@end
