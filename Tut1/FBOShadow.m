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
    GLuint _colorRBO;
}
@property (strong, nonatomic) GLSLProgram *program;
@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;
@property (assign, nonatomic) GLuint name;
@property (assign, nonatomic) GLenum target;

@end

#pragma mark

@implementation FBOShadow

@synthesize program = _program;
@synthesize name = _depthTex;

- (id)init
{
    return [self initWithWidth:1024 andHeight:1024];
}

- (id)initWithWidth:(GLsizei)width andHeight:(GLsizei)height
{
#if defined(GL_OES_depth_texture)
    if (self = [super init]) {
        _program = nil;
        _width = width;
        _height = height;
        _light = nil;
        _target = GL_TEXTURE_2D;

        // Assign the shadow map to texture channel 0
        glActiveTexture(GL_TEXTURE0);

        glGenTextures(1, &_depthTex);
        glBindTexture(GL_TEXTURE_2D, _depthTex);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);  // GL_NEAREST
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);  // GL_NEAREST
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_COMPARE_REF_TO_TEXTURE_EXT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_EXT, GL_LEQUAL);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);

        // Create and set up the FBO
        glGenFramebuffers(1, &_handle);
        glBindFramebuffer(GL_FRAMEBUFFER, _handle);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                               GL_TEXTURE_2D, _depthTex, 0);

        // GLenum drawBuffers[] = {GL_NONE};
        // glDrawBuffers(1, drawBuffers); or glDrawBuffer(GL_NONE);
        // But OpenGL ES 2.0 doesn't have them.
        // As workaround just don't create render color-buffer or attach one

        GLenum result = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (result != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Framebuffer is not complete: %x", result);
            self = nil;
        }

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

    glDeleteRenderbuffers(1, &_colorRBO);
    glDeleteFramebuffers(1, &_handle);
	glDeleteTextures(1, &_depthTex);
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
