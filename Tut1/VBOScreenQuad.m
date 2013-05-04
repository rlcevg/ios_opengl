//
//  VBOScreenQuad.m
//  Tut1
//
//  Created by Evgenij on 5/4/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "VBOScreenQuad.h"
#import "Utils.h"

#pragma mark

@interface VBOScreenQuad () {
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@end

#pragma mark

@implementation VBOScreenQuad

- (id)init
{
    if (self = [super init]) {
        static GLKVector2 data[4] = {
            {0.0, 0.0},
            {1.0, 0.0},
            {0.0, 1.0},
            {1.0, 1.0}
        };
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);

        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(data), data, GL_STATIC_DRAW);

        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLKVector2), BUFFER_OFFSET(0));

        glBindVertexArrayOES(0);
    }
    return self;
}

- (void)dealloc
{
	glDeleteBuffers(1, &_vertexBuffer);
	glDeleteVertexArraysOES(1, &_vertexArray);
}

- (void)render
{
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
