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

#define N_FBOS 2
//#define N_TEXTURES 3
#define N_TEXTURES 2
#define DEPTH_DATA_TEX 0
#define BLUR_DEPTH_TEX0 1
//#define BLUR_DEPTH_TEX1 2
#define SHADOW_FBO 0
#define BLUR_FBO 1
#define BLUR_COEF 1

#pragma mark

@interface FBOShadow () {
    GLuint _fbos[N_FBOS];
    GLuint _rboDepth;
    GLuint _textures[N_TEXTURES];
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
    return [self initWithWidth:1024 height:1024];
}

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height
{
    if (self = [super init]) {
        _quad = [VBOScreenQuad new];
        _program = nil;
        _programBlur = nil;
        _width = width;
        _height = height;
        _light = nil;
        _target = GL_TEXTURE_2D;

        glGenTextures(N_TEXTURES, _textures);
        glGenFramebuffers(N_FBOS, _fbos);

        // Create depth renderbuffer
        glGenRenderbuffers(1, &_rboDepth);
        glBindRenderbuffer(GL_RENDERBUFFER, _rboDepth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, width, height);

        // Create depth data texture
        glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_HALF_FLOAT_OES, NULL);

        // Create and set up the depth FBO
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[SHADOW_FBO]);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rboDepth);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX], 0);

        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Depth framebuffer is not complete: %x", fboStatus);
            return nil;
        }

        // Create blur0 color texture
        glBindTexture(GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        GLfloat fLargest;
        glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &fLargest);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, fLargest);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width >> BLUR_COEF, height >> BLUR_COEF, 0, GL_RGBA, GL_HALF_FLOAT_OES, 0);

        // Creating the blurred FBO
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[BLUR_FBO]);

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX0], 0);

        fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Blur framebuffer is not complete: %x", fboStatus);
            return nil;
        }

//        // Create blur1 color texture
//        glBindTexture(GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX1]);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width >> BLUR_COEF, height >> BLUR_COEF, 0, GL_RGBA, GL_HALF_FLOAT_OES, 0);

        glBindTexture(GL_TEXTURE_2D, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    return self;
}

- (void)dealloc
{
//    self.program = nil;
//    self.programBlur = nil;
//    self.quad = nil;

    glDeleteFramebuffers(N_FBOS, _fbos);
	glDeleteTextures(N_TEXTURES, _textures);
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
        if (![_programBlur loadShaders:@"BlurBox5" withAttrs:attrs]) {
            [_programBlur printLog];
        }
    }
    return _programBlur;
}

- (void)prepareToDraw
{
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[SHADOW_FBO]);
    glViewport(0, 0, _width, _height);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (GLuint)name
{
    return _textures[BLUR_DEPTH_TEX0];
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

- (void)process
{
    GLSLProgram *program = self.programBlur;
    [program use];

    glDisable(GL_DEPTH_TEST);
    glActiveTexture(GL_TEXTURE0);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[BLUR_FBO]);
    glViewport(0, 0, _width >> BLUR_COEF, _height >> BLUR_COEF);
    [program setUniform:"texSampler" valInt:0];

    glBindTexture(GL_TEXTURE_2D, _textures[DEPTH_DATA_TEX]);
    glGenerateMipmap(GL_TEXTURE_2D);
//    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX1], 0);
//    [program setUniform:"scale" vec2:GLKVector2Make(1.0 / (_width >> BLUR_COEF), 0.0)];
    [program setUniform:"scale" vec2:GLKVector2Make(1.0 / (_width >> BLUR_COEF), 1.0 / (_height >> BLUR_COEF))];
    [self.quad render];

//    glBindTexture(GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX1]);
//    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX0], 0);
//    [program setUniform:"scale" vec2:GLKVector2Make(0.0, 1.0 / (_height >> BLUR_COEF))];
//    [self.quad render];

    glBindTexture(GL_TEXTURE_2D, _textures[BLUR_DEPTH_TEX0]);
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
