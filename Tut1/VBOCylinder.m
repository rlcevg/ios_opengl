//
//  VBOCylinder.m
//  Tut1
//
//  Created by Evgenij on 5/6/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "VBOCylinder.h"
#import "Utils.h"
#import <OpenGLES/ES2/glext.h>

#pragma mark

@interface VBOCylinder () {
    GLuint _vertexArray;
    GLuint _vertexBuffer[2];
}

@end

#pragma mark

@implementation VBOCylinder

- (id)init
{
    if (self = [super init]) {
        _constantColor = GLKVector3Make(0.8, 0.8, 0.8);
        typedef struct {
            GLKVector3 vert;
            GLKVector3 norm;
        } Vertex;
        Vertex frontRearCircle[40];
        float radius = 0.1;
        for (int i = 0; i < 20; i++) {
            float angle = 2 * M_PI/20.0 * i;
            frontRearCircle[i].vert = GLKVector3Make(radius * cos(angle), radius * sin(angle), 4.0);
            frontRearCircle[i].norm = GLKVector3Make(cos(angle), sin(angle), 0.0);
            frontRearCircle[i+20].vert = frontRearCircle[i].vert;
            frontRearCircle[i+20].vert.z *= -1.0;
            frontRearCircle[i+20].norm = frontRearCircle[i].norm;
        }

        GLuint side[6 * 20];
        for (GLuint i = 0; i < 19; i++) {
            side[i * 6 + 0] = 20 + i;
            side[i * 6 + 1] = i + 1;
            side[i * 6 + 2] = i;

            side[i * 6 + 3] = 20 + i;
            side[i * 6 + 4] = 20 + i + 1;
            side[i * 6 + 5] = i + 1;
        }
        GLuint i = 19;
        side[i * 6 + 0] = 20 + i;
        side[i * 6 + 1] = 0;
        side[i * 6 + 2] = i;

        side[i * 6 + 3] = 20 + i;
        side[i * 6 + 4] = 20;
        side[i * 6 + 5] = 0;

        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);

        glGenBuffers(2, _vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer[0]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(frontRearCircle), frontRearCircle, GL_STATIC_DRAW);

        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(offsetof(Vertex, vert)));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_OFFSET(offsetof(Vertex, norm)));

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vertexBuffer[1]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * 20 * sizeof(GLuint), side, GL_STATIC_DRAW);

        glBindVertexArrayOES(0);
    }
    return self;
}

- (void)dealloc
{
	glDeleteBuffers(2, _vertexBuffer);
	glDeleteVertexArraysOES(1, &_vertexArray);
}

- (void)render
{
    glDisable(GL_CULL_FACE);
    glBindVertexArrayOES(_vertexArray);
    glDrawElements(GL_TRIANGLES, 6 * 20, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    glEnable(GL_CULL_FACE);
}

@end
