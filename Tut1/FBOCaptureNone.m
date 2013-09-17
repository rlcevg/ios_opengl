//
//  FBOCaptureNone.m
//  Tut1
//
//  Created by Evgenij on 9/8/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "FBOCaptureNone.h"

#pragma mark

@interface FBOCaptureNone () {
    GLuint _fbo;
    GLuint _rboDepth;
}
@property (assign, nonatomic, readwrite, getter=isChanged) BOOL changed;

@end

#pragma mark

@implementation FBOCaptureNone

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height
{
    if (self = [super initWithWidth:width height:height]) {
        glGenTextures(1, &_texture);
        glGenFramebuffers(1, &_fbo);
        glGenRenderbuffers(1, &_rboDepth);

        glBindRenderbuffer(GL_RENDERBUFFER, _rboDepth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, width, height);

        glBindTexture(GL_TEXTURE_2D, _texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

        glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rboDepth);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Capture framebuffer is not complete: %x", fboStatus);
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
    glDeleteFramebuffers(1, &_fbo);
    glDeleteTextures(1, &_texture);
    glDeleteRenderbuffers(1, &_rboDepth);
}

- (void)prepareToDraw
{
    if (self.changed) {
        glBindRenderbuffer(GL_RENDERBUFFER, _rboDepth);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, self.width, self.height);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.width, self.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glBindTexture(GL_TEXTURE_2D, 0);
        self.changed = NO;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    glViewport(0, 0, self.width, self.height);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

@end
