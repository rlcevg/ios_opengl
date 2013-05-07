//
//  FBOBloom.m
//  Tut1
//
//  Created by Evgenij on 4/29/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "FBOBloom.h"
#import "VBOScreenQuad.h"
#import "GLSLProgram.h"

#define FILTER_COUNT  4
#define CAPTURE_TEX (FILTER_COUNT * 2)
#define HIGH_TEX (FILTER_COUNT * 2 + 1)
#define CAPTURE_FBO (FILTER_COUNT)
#define HIGH_FBO (FILTER_COUNT + 1)
#define N_TEXTURES (FILTER_COUNT * 2 + 2)
#define N_FBOS (FILTER_COUNT + 2)

#pragma mark

@interface FBOBloom () {
    GLuint _fbos[N_FBOS];
    GLuint _rboDepth;
    GLuint _textures[N_TEXTURES];
}
@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;
@property (strong, nonatomic) VBOScreenQuad *quad;
@property (strong, nonatomic) GLSLProgram *programHigh;
@property (strong, nonatomic) GLSLProgram *programBlur;
@property (strong, nonatomic) GLSLProgram *programCombine;
@property (assign, nonatomic, getter=isChanged) BOOL changed;

@end

#pragma mark

@implementation FBOBloom

- (id)initWithScreenWidth:(GLsizei)width andScreenHeight:(GLsizei)height
{
    return [self initWithBloomWidth:256 bloomHeight:256 screenWidth:width screenHeight:height];
}

- (id)initWithBloomWidth:(GLsizei)width bloomHeight:(GLsizei)height
             screenWidth:(GLsizei)scrWidth screenHeight:(GLsizei)scrHeight
{
    if (self = [super init]) {
        _quad = [VBOScreenQuad new];
        _width = width;
        _height = height;
        _scrWidth = scrWidth;
        _scrHeight = scrHeight;

        glGenTextures(N_TEXTURES, _textures);
        glGenFramebuffers(N_FBOS, _fbos);
        glGenRenderbuffers(1, &_rboDepth);

        glBindRenderbuffer(GL_RENDERBUFFER, _rboDepth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, scrWidth, scrHeight);

        glBindTexture(GL_TEXTURE_2D, _textures[CAPTURE_TEX]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, scrWidth, scrHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[CAPTURE_FBO]);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rboDepth);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[CAPTURE_TEX], 0);
        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Capture framebuffer is not complete: %x", fboStatus);
            return nil;
        }

        glBindTexture(GL_TEXTURE_2D, _textures[HIGH_TEX]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[HIGH_FBO]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[HIGH_TEX], 0);
        fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"High framebuffer is not complete: %x", fboStatus);
            return nil;
        }

        for (int i = 0; i < FILTER_COUNT; i++) {
            glBindTexture(GL_TEXTURE_2D, _textures[i]);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width >> i, height >> i, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

            glBindFramebuffer(GL_FRAMEBUFFER, _fbos[i]);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[i], 0);
            fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
            if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
                NSLog(@"Bloom%d framebuffer is not complete: %x", i, fboStatus);
                return nil;
            }
        }
        for (int i = 0; i < FILTER_COUNT; i++) {
            glBindTexture(GL_TEXTURE_2D, _textures[i + FILTER_COUNT]);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width >> i, height >> i, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        }

        glBindTexture(GL_TEXTURE_2D, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    return self;
}

- (void)dealloc
{
    self.programHigh = nil;
    self.programBlur = nil;
    self.quad = nil;

    glDeleteFramebuffers(N_FBOS, _fbos);
	glDeleteTextures(N_TEXTURES, _textures);
    glDeleteRenderbuffers(1, &_rboDepth);
}

- (GLSLProgram *)programHigh
{
    if (!_programHigh) {
        _programHigh = [GLSLProgram new];
        NSDictionary *attrs = @{
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        if (![_programHigh loadShaders:@"BloomHigh" withAttrs:attrs]) {
            [_programHigh printLog];
        }
    }
    return _programHigh;
}

- (GLSLProgram *)programBlur
{
    if (!_programBlur) {
        _programBlur = [GLSLProgram new];
        NSDictionary *attrs = @{
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        if (![_programBlur loadShaders:@"BlurGaussian7" withAttrs:attrs]) {
            [_programBlur printLog];
        }
    }
    return _programBlur;
}

- (GLSLProgram *)programCombine
{
    if (!_programCombine) {
        _programCombine = [GLSLProgram new];
        NSDictionary *attrs = @{
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        if (![_programCombine loadShaders:@"BloomCombine4" withAttrs:attrs]) {
            [_programCombine printLog];
        }
    }
    return _programCombine;
}

- (void)setScrWidth:(GLsizei)scrWidth
{
    if (_scrWidth != scrWidth) {
        _scrWidth = scrWidth;
        self.changed = YES;
    }
}

- (void)setScrHeight:(GLsizei)scrHeight
{
    if (_scrHeight != scrHeight) {
        _scrHeight = scrHeight;
        self.changed = YES;
    }
}

- (void)prepareToDraw
{
    if (self.changed) {
        glBindRenderbuffer(GL_RENDERBUFFER, _rboDepth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, _scrWidth, _scrHeight);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, _textures[CAPTURE_TEX]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _scrWidth, _scrHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glBindTexture(GL_TEXTURE_2D, 0);
        self.changed = NO;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[CAPTURE_FBO]);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _scrWidth, _scrHeight);
}

- (void)process
{
    glDisable(GL_DEPTH_TEST);

    // Hi-pass
    GLSLProgram *program = self.programHigh;
    [program use];
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[HIGH_FBO]);
    glViewport(0, 0, _width, _height);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textures[CAPTURE_TEX]);
    [program setUniform:"texSampler" valInt:0];
    [self.quad render];
    glBindTexture(GL_TEXTURE_2D, _textures[HIGH_TEX]);
    glGenerateMipmap(GL_TEXTURE_2D);

    // Perform the horizontal blurring pass
    program = self.programBlur;
    [program use];
    for (int i = 0; i < FILTER_COUNT; i++) {
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[i]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[i + FILTER_COUNT], 0);
        GLsizei width_i = _width >> i;
        GLsizei height_i = _height >> i;
        glViewport(0, 0, width_i, height_i);
        [program setUniform:"direction" valBool:YES];
        [program setUniform:"scale" vec2:GLKVector2Make(1.0 / width_i, 0.0)];
        [self.quad render];
    }

    // Perform the vertical blurring pass
    for (int i = 0; i < FILTER_COUNT; i++) {
        glBindTexture(GL_TEXTURE_2D, _textures[i + FILTER_COUNT]);
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[i]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[i], 0);
        GLsizei width_i = _width >> i;
        GLsizei height_i = _height >> i;
        glViewport(0, 0, width_i, height_i);
        [program setUniform:"direction" valBool:NO];
        [program setUniform:"scale" vec2:GLKVector2Make(0.0, 1.0 / height_i)];
        [self.quad render];
    }

    glEnable(GL_DEPTH_TEST);
}

- (void)render
{
    GLSLProgram *program = self.programCombine;
    [program use];
    char name[] = "Pass#";
    for (int i = 0; i < FILTER_COUNT; i++) {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        sprintf(name, "pass%d", i);
        [program setUniform:name valInt:i];
    }
    glActiveTexture(GL_TEXTURE0 + FILTER_COUNT);
    glBindTexture(GL_TEXTURE_2D, _textures[CAPTURE_TEX]);
    [program setUniform:"scene" valInt:FILTER_COUNT];
    [self.quad render];
}

@end
