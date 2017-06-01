//
//  VAOQuad.m
//  Tut1
//
//  Created by Evgenij on 9/19/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "VAOQuad.h"
#import "Utils.h"
#import <OpenGLES/ES2/glext.h>

#pragma mark

@interface VAOQuad () {
    GLuint _vertexArray;
    GLKVector3 _data[4];
}

@end

#pragma mark

@implementation VAOQuad

//- (id)init
//{
//    static GLKVector3 data[4] = {
//        {0.0, 0.0, 0.0},
//        {1.0, 0.0, 0.0},
//        {0.0, 1.0, 0.0},
//        {1.0, 1.0, 0.0}
//    };
//    return [self initWithData:data];
//}

- (id)initWithData:(const GLKVector3 *)data
{
    if (self = [super init]) {
        [self updateWithData:data];

        glGenVertexArraysOES(1, &_vertexArray);
    }
    return self;
}

- (void)dealloc
{
	glDeleteVertexArraysOES(1, &_vertexArray);
}

- (GLKVector3 *)data
{
    return _data;
}

- (void)render
{
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), _data);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), _data);
//    glEnableVertexAttribArray(GLKVertexAttribNormal);
//    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), _data);
//    glEnableVertexAttribArray(GLKVertexAttribColor);

//    glDisable(GL_CULL_FACE);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glEnable(GL_CULL_FACE);
}

- (void)updateWithData:(const GLKVector3 *)data
{
    memcpy(_data, data, sizeof(GLKVector3) * 4);
}

@end
