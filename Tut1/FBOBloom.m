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
#import "FBOCapture.h"
#import "GLSLBlur.h"

#define FILTER_COUNT 3
#define HIGH_TEX (FILTER_COUNT * 2)
#define HIGH_FBO (FILTER_COUNT)
#define N_TEXTURES (FILTER_COUNT * 2 + 1)
#define N_FBOS (FILTER_COUNT + 1)

#pragma mark

@interface FBOBloom () {
    GLuint _fbos[N_FBOS];
    GLuint _textures[N_TEXTURES];
    GLuint _captureTexture;
}
@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;
@property (strong, nonatomic) VBOScreenQuad *quad;
@property (strong, nonatomic) GLSLProgram *programHigh;
@property (strong, nonatomic) GLSLBlur *blur;
@property (strong, nonatomic) GLSLProgram *programCombine;

@end

#pragma mark

@implementation FBOBloom

- (id)initWithCaptureFramebuffer:(FBOCapture *)capture
{
    return [self initWithWidth:256 height:128 captureFramebuffer:capture];
}

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height captureFramebuffer:(FBOCapture *)capture
{
    if (self = [super init]) {
        _quad = [VBOScreenQuad screenQuad];
        _width = width;
        _height = height;
        _capture = capture;

        glGenTextures(N_TEXTURES, _textures);
        glGenFramebuffers(N_FBOS, _fbos);

        glBindTexture(GL_TEXTURE_2D, _textures[HIGH_TEX]);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[HIGH_FBO]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[HIGH_TEX], 0);
        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
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
//    self.programHigh = nil;
//    self.blur = nil;
//    self.programCombine = nil;
//    self.quad = nil;
//    self.capture = nil;

    glDeleteFramebuffers(N_FBOS, _fbos);
	glDeleteTextures(N_TEXTURES, _textures);
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

- (GLSLBlur *)blur
{
    if (!_blur) {
        _blur = [GLSLBlur new];
    }
    return _blur;
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

- (void)prepareToDraw
{
    [self.capture prepareToDraw];
}

- (void)process
{
    glDisable(GL_DEPTH_TEST);
    _captureTexture = self.capture.texture;

    // Hi-pass
    GLSLProgram *program = self.programHigh;
    [program use];
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[HIGH_FBO]);
    glViewport(0, 0, _width, _height);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _captureTexture);
    [program setUniform:"texSampler" valInt:0];
    [self.quad render];
    glBindTexture(GL_TEXTURE_2D, _textures[HIGH_TEX]);
//    glGenerateMipmap(GL_TEXTURE_2D);

    // Perform the horizontal blurring pass
    GLSLBlur *blur = self.blur;
    [blur use];
    for (int i = 0; i < FILTER_COUNT; i++) {
        if (i > 0) {
            glBindTexture(GL_TEXTURE_2D, _textures[i + FILTER_COUNT - 1]);
        }
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[i]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textures[i + FILTER_COUNT], 0);
        GLsizei width_i = _width >> i;
        GLsizei height_i = _height >> i;
        glViewport(0, 0, width_i, height_i);
        [blur setTexelSize:GLKVector2Make(1.0 / width_i, 0.0)];
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
        [blur setTexelSize:GLKVector2Make(0.0, 1.0 / height_i)];
        [self.quad render];
    }

    glEnable(GL_DEPTH_TEST);
}

- (void)render
{
    glDisable(GL_DEPTH_TEST);
    GLSLProgram *program = self.programCombine;
    [program use];
    char name[] = "pass#";
    for (int i = 0; i < FILTER_COUNT; i++) {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        sprintf(name, "pass%d", i);
        [program setUniform:name valInt:i];
    }
    glActiveTexture(GL_TEXTURE0 + FILTER_COUNT);
    glBindTexture(GL_TEXTURE_2D, _captureTexture);
//    glBindTexture(GL_TEXTURE_2D, 0);
    [program setUniform:"scene" valInt:FILTER_COUNT];
    [self.quad render];
    glEnable(GL_DEPTH_TEST);
}

@end
