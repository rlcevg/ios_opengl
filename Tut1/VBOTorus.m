//
//  VBOTorus.m
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "VBOTorus.h"
#import "Utils.h"
#import <GLKit/GLKit.h>

#pragma mark

@interface VBOTorus () {
    GLuint _vaoHandle;
    GLuint _handle[5];
    unsigned int _faces;
}

@end

#pragma mark

@implementation VBOTorus

- (id)init
{
    return [self initWithOuterRadius:2.0 innerRadius:1.0 nsides:20 nrings:40];
}

- (id)initWithOuterRadius:(float)outerRadius innerRadius:(float)innerRadius nsides:(int) nsides nrings:(int) nrings
{
    self = [super init];

    if (self) {
        _faces = nsides * nrings;
        int nVerts  = nsides * (nrings+1);   // One extra ring to duplicate first ring

        // Verts
        GLfloat *v = (GLfloat *)malloc(sizeof(GLfloat) * 3 * nVerts);
        // Normals
        GLfloat *n = (GLfloat *)malloc(sizeof(GLfloat) * 3 * nVerts);
        // Tex coords
        GLfloat *tex = (GLfloat *)malloc(sizeof(GLfloat) * 2 * nVerts);
        // Colors
        GLfloat *c = (GLfloat *)malloc(sizeof(GLfloat) * 4 * nVerts);
        // Elements
        GLuint *el = (GLuint *)malloc(sizeof(GLuint) * 6 * _faces);

        // Generate the vertex data
        [VBOTorus generateVerts:v norms:n colors:c tex:tex el:el outerRadius:outerRadius
                    innerRadius:innerRadius sides:nsides rings:nrings];

        // Create the VAO
        glGenVertexArraysOES(1, &_vaoHandle);
        glBindVertexArrayOES(_vaoHandle);

        // Create and populate the buffer objects
        glGenBuffers(5, _handle);

        glBindBuffer(GL_ARRAY_BUFFER, _handle[0]);
        glBufferData(GL_ARRAY_BUFFER, (3 * nVerts) * sizeof(GLfloat), v, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribPosition);  // Vertex position

        glBindBuffer(GL_ARRAY_BUFFER, _handle[1]);
        glBufferData(GL_ARRAY_BUFFER, (3 * nVerts) * sizeof(GLfloat), n, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);  // Vertex normal

        glBindBuffer(GL_ARRAY_BUFFER, _handle[2]);
        glBufferData(GL_ARRAY_BUFFER, (4 * nVerts) * sizeof(GLfloat), c, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribColor);  // Vertex color

        glBindBuffer(GL_ARRAY_BUFFER, _handle[3]);
        glBufferData(GL_ARRAY_BUFFER, (2 * nVerts) * sizeof(GLfloat), tex, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);  // Texture coords

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _handle[4]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * _faces * sizeof(GLuint), el, GL_STATIC_DRAW);

        glBindVertexArrayOES(0);
        
        free(v);
        free(n);
        free(c);
        free(tex);
        free(el);
    }

    return self;
}

- (void)dealloc
{
	glDeleteBuffers(5, _handle);
	glDeleteVertexArraysOES(1, &_vaoHandle);
}

- (void)render
{
    glBindVertexArrayOES(_vaoHandle);
    glDrawElements(GL_TRIANGLES, 6 * _faces, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
}

+ (void)generateVerts:(GLfloat *)verts norms:(GLfloat *)norms colors:(GLfloat *)colors
                  tex:(GLfloat *)tex el:(GLuint *)el
          outerRadius:(float)outerRadius innerRadius:(float)innerRadius
                sides:(int)sides rings:(int)rings
{
    float ringFactor  = (float)(TWOPI / rings);
    float sideFactor = (float)(TWOPI / sides);
    int idx = 0, tidx = 0, cidx = 0;
    for (int ring = 0; ring <= rings; ring++) {
        float u = ring * ringFactor;
        float cu = cos(u);
        float su = sin(u);
        for (int side = 0; side < sides; side++) {
            float v = side * sideFactor;
            float cv = cos(v);
            float sv = sin(v);
            float r = (outerRadius + innerRadius * cv);
            verts[idx] = r * cu;
            verts[idx + 1] = r * su;
            verts[idx + 2] = innerRadius * sv;
            norms[idx] = cv * cu * r;
            norms[idx + 1] = cv * su * r;
            norms[idx + 2] = sv * r;
            tex[tidx] = (float)(u / TWOPI);
            tex[tidx+1] = (float)(v / TWOPI);
            tidx += 2;
            // Normalize
            float len = sqrt(norms[idx] * norms[idx] +
                             norms[idx + 1] * norms[idx + 1] +
                             norms[idx + 2] * norms[idx + 2]);
            norms[idx] /= len;
            norms[idx + 1] /= len;
            norms[idx + 2] /= len;
            idx += 3;
            colors[cidx] = arc4random() / RAND_MAX;
            colors[cidx + 1] = arc4random() / RAND_MAX;
            colors[cidx + 2] = arc4random() / RAND_MAX;
            colors[cidx + 3] = 1.0;
            cidx += 4;
        }
    }

    idx = 0;
    for (int ring = 0; ring < rings; ring++) {
        int ringStart = ring * sides;
        int nextRingStart = (ring + 1) * sides;
        for (int side = 0; side < sides; side++) {
            int nextSide = (side + 1) % sides;
            // The quad
            el[idx] = (ringStart + side);
            el[idx + 1] = (nextRingStart + side);
            el[idx + 2] = (nextRingStart + nextSide);
            el[idx + 3] = ringStart + side;
            el[idx + 4] = nextRingStart + nextSide;
            el[idx + 5] = (ringStart + nextSide);
            idx += 6;
        }
    }
}

@end
