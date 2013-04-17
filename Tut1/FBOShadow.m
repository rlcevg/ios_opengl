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

#pragma mark

@interface FBOShadow () {
    GLuint _handle;
    GLuint _depthTex;
    GLuint _renderBuffer;
    GLuint _colorRenderbuffer;
    GLuint _colorTex;
    GLuint _renderBuffer2;
}
@property (strong, nonatomic) GLSLProgram *program;
@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;

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
#if defined(GL_OES_depth_texture) && defined(GL_OES_depth24)
    if (self = [super init]) {
        _program = nil;
        _width = width;
        _height = height;
        _light = nil;

//        // Assign the shadow map to texture channel 0
//        glActiveTexture(GL_TEXTURE0);
//
//        glGenTextures(1, &_depthTex);
//        glBindTexture(GL_TEXTURE_2D, _depthTex);
//
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_COMPARE_REF_TO_TEXTURE_EXT);
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_NONE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_EXT, GL_ALWAYS);
//
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
//
//        // Create and set up the FBO
//        glGenFramebuffers(1, &_handle);
//        glBindFramebuffer(GL_FRAMEBUFFER, _handle);
//        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
//                               GL_TEXTURE_2D, _depthTex, 0);
//
//        // GLenum drawBuffers[] = {GL_NONE};
//        // glDrawBuffers(1, drawBuffers); or glDrawBuffer(GL_NONE);
//        // OpenGL ES 2.0 must have a buffer to render to. Create one
//        glGenRenderbuffers(1, &_renderBuffer);
//        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
//        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
//        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _renderBuffer);



        /* Texture */
        glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, &_colorTex);
        glBindTexture(GL_TEXTURE_2D, _colorTex);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 480, 320, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, 480, 320, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
        glBindTexture(GL_TEXTURE_2D, 0);

        /* Depth buffer */
        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        NSLog(@"0x%x", glGetError());
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA4_OES, 480, 320);
        NSLog(@"0x%x", glGetError());
        glBindRenderbuffer(GL_RENDERBUFFER, 0);

        /* Framebuffer to link everything together */
        glGenFramebuffers(1, &_handle);
        glBindFramebuffer(GL_FRAMEBUFFER, _handle);
        NSLog(@"0x%x", glGetError());
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);

        glGenRenderbuffers(1, &_renderBuffer2);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer2);
        NSLog(@"0x%x", glGetError());
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA4_OES, 480, 320);
        NSLog(@"0x%x", glGetError());
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _renderBuffer2);
        NSLog(@"0x%x", glGetError());
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _colorTex, 0);

        NSLog(@"0x%x", glGetError());



        GLenum result = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (result == GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Framebuffer is complete.");
        } else {
            NSLog(@"Framebuffer is not complete: %x", result);
            self = nil;
        }

        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        // Revert to the default framebuffer for now
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
#else
    self = nil;
#endif
    return self;
}

- (void)dealloc
{
    self.program = nil;

    glDeleteRenderbuffers(1, &_colorRenderbuffer);
    glDeleteRenderbuffers(1, &_renderBuffer);
    glDeleteFramebuffers(1, &_handle);
	glDeleteTextures(1, &_depthTex);
	glDeleteTextures(1, &_colorTex);
}

- (GLSLProgram *)program
{
    if (!_program) {
        _program = [GLSLProgram new];
        if (![_program loadShaders:@"Shadow"]) {
            [_program printLog];
        }
    }
    return _program;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        if (enabled) {
            glBindFramebuffer(GL_FRAMEBUFFER, _handle);
            glClear(GL_DEPTH_BUFFER_BIT);
            glViewport(0, 0, _width, _height);
            glCullFace(GL_FRONT);
            glEnable(GL_POLYGON_OFFSET_FILL);
        } else {
            glDisable(GL_POLYGON_OFFSET_FILL);
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
        }
        _enabled = enabled;
    }
}

- (void)prepareToDraw:(id<Drawable>)object
{
    GLSLProgram *program = self.program;
    [program use];

    if (self.light) {
        GLKMatrix4 modelviewMatrix = GLKMatrix4Multiply(self.light.viewMatrix, object.modelMatrix);
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.light.projectionMatrix, modelviewMatrix);
        [program setUniform:"modelViewProjectionMatrix" mat4:modelViewProjectionMatrix];
    }
}

+ (GLKMatrix4)shadowBias
{
    return GLKMatrix4Make(0.5f, 0.0f, 0.0f, 0.0f,
                          0.0f, 0.5f, 0.0f, 0.0f,
                          0.0f, 0.0f, 0.5f, 0.0f,
                          0.5f, 0.5f, 0.5f, 1.0f);
}

@end
