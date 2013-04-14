//
//  VBOFloor.m
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "VBOFloor.h"
#import "Utils.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 tex;
} Vertex;

#pragma mark

@interface VBOFloor () {
    GLuint _vaoHandle;
    GLuint _handle[3];
    unsigned int _faces;
}

@end

#pragma mark

@implementation VBOFloor

- (id)init
{
    return [self initWithXsize:20.0f zsize:20.0f xdivs:20 zdivs:20];
}

- (id)initWithXsize:(float)xsize zsize:(float)zsize xdivs:(int)xdivs zdivs:(int)zdivs
{
    self = [super init];

    if (self) {
        glGenVertexArraysOES(1, &_vaoHandle);
        glBindVertexArrayOES(_vaoHandle);
        _faces = xdivs * zdivs;

        Vertex *vertices = (Vertex *)malloc(sizeof(Vertex) * (xdivs + 1) * (zdivs + 1));
        GLuint *el = (GLuint *)malloc(sizeof(GLuint) * 6 * xdivs * zdivs);

        float x2 = xsize / 2.0f;
        float z2 = zsize / 2.0f;
        float iFactor = (float)zsize / zdivs;
        float jFactor = (float)xsize / xdivs;
        float texi = 1.0f / zdivs;
        float texj = 1.0f / xdivs;
        float x, z;
        Vertex *pVert = vertices;
        float c1 = 4 / x2, c2 = 4 / z2, c3 = 2;
        for (int i = 0; i <= zdivs; i++) {
            z = iFactor * i - z2;
            for (int j = 0; j <= xdivs; j++) {
                x = jFactor * j - x2;
                float sinVal = sinf(c1 * x), cosVal = cosf(c2 * z);
                pVert->position.x = x;
                pVert->position.y = sinVal * cosVal * c3;
                pVert->position.z = z;
                pVert->normal = GLKVector3Normalize(GLKVector3Make(
                                    -c1 * c3 * cosVal * cosf(c1 * x),
                                    1.0,
                                    c2 * c3 * sinVal * sinf(c2 * z)));
                pVert->tex.x = i * texi;
                pVert->tex.y = j * texj;
                pVert += 1;
            }
        }

        unsigned int rowStart, nextRowStart;
        int idx = 0;
        for (int i = 0; i < zdivs; i++) {
            rowStart = i * (xdivs+1);
            nextRowStart = (i+1) * (xdivs+1);
            for (int j = 0; j < xdivs; j++) {
                el[idx] = rowStart + j;
                el[idx+1] = nextRowStart + j;
                el[idx+2] = nextRowStart + j + 1;
                el[idx+3] = rowStart + j;
                el[idx+4] = nextRowStart + j + 1;
                el[idx+5] = rowStart + j + 1;
                idx += 6;
            }
        }

        glGenBuffers(3, _handle);

        glBindBuffer(GL_ARRAY_BUFFER, _handle[0]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * (xdivs + 1) * (zdivs + 1), vertices, GL_STATIC_DRAW);
        glVertexAttribPointer((GLuint)0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, position));
        glEnableVertexAttribArray(0);  // Vertex position
        glVertexAttribPointer((GLuint)1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, normal));
        glEnableVertexAttribArray(1);  // Vertex normal
        glVertexAttribPointer((GLuint)3, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, tex));
        glEnableVertexAttribArray(3);  // Texture coords
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _handle[1]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * xdivs * zdivs * sizeof(GLuint), el, GL_STATIC_DRAW);
        
        free(vertices);
        free(el);
    }

    return self;
}

- (void)dealloc
{
	glDeleteBuffers(3, _handle);
	glDeleteVertexArraysOES(1, &_vaoHandle);
}

- (void)render
{
    glBindVertexArrayOES(_vaoHandle);
    glVertexAttrib3f(1, 0.0f, 1.0f, 0.0f);  // Constant normal for all verts
    glDrawElements(GL_TRIANGLES, 6 * _faces, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
}

@end
