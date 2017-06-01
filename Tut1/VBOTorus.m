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
#import <OpenGLES/ES2/glext.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
} Vertex;

void generateVertexData(Vertex *vertices, int sides, int rings,
                        float outerRadius, float innerRadius, float time);

#pragma mark

@interface VBOTorus () {
    GLuint _vaoHandle;
    GLuint _handle[6];
    unsigned int _faces;

    int _sides;
    int _rings;
    float _outerRadius;
    float _innerRadius;

    int _bufferID;
}

@end

#pragma mark

@implementation VBOTorus

- (id)init
{
    return [self initWithOuterRadius:1.0 innerRadius:0.3 nsides:40 nrings:60];
}

- (id)initWithOuterRadius:(float)outerRadius innerRadius:(float)innerRadius nsides:(int) nsides nrings:(int) nrings
{
    if (self = [super init]) {
        _bufferID = 2;
        _sides = nsides;
        _rings = nrings;
        _outerRadius = outerRadius;
        _innerRadius = innerRadius;
        _faces = nsides * nrings;
        int nVerts  = nsides * (nrings + 1);   // One extra ring to duplicate first ring

        // Verts and Normals
        Vertex *vertices = (Vertex *)malloc(sizeof(Vertex) * nVerts);
        // Tex coords
        GLfloat *tex = (GLfloat *)malloc(sizeof(GLfloat) * 2 * nVerts);
        // Colors
        GLfloat *c = (GLfloat *)malloc(sizeof(GLfloat) * 4 * nVerts);
        // Elements
        GLuint *el = (GLuint *)malloc(sizeof(GLuint) * 6 * _faces);

        // Generate the vertex data
        [VBOTorus generateVerts:vertices colors:c tex:tex el:el outerRadius:outerRadius
                    innerRadius:innerRadius sides:nsides rings:nrings];

        // Create the VAO
        glGenVertexArraysOES(1, &_vaoHandle);
        glBindVertexArrayOES(_vaoHandle);

        // Create and populate the buffer objects
        glGenBuffers(6, _handle);

        for (int i = 0; i < 3; ++i) {
            glBindBuffer(GL_ARRAY_BUFFER, _handle[i]);
            glBufferData(GL_ARRAY_BUFFER, nVerts * sizeof(Vertex), vertices, GL_DYNAMIC_DRAW);
        }
        glEnableVertexAttribArray(GLKVertexAttribPosition);  // Vertex position
        glEnableVertexAttribArray(GLKVertexAttribNormal);  // Vertex normal

        glBindBuffer(GL_ARRAY_BUFFER, _handle[3]);
        glBufferData(GL_ARRAY_BUFFER, (4 * nVerts) * sizeof(GLfloat), c, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribColor);  // Vertex color

        glBindBuffer(GL_ARRAY_BUFFER, _handle[4]);
        glBufferData(GL_ARRAY_BUFFER, (2 * nVerts) * sizeof(GLfloat), tex, GL_STATIC_DRAW);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);  // Texture coords

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _handle[5]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * _faces * sizeof(GLuint), el, GL_STATIC_DRAW);

        glBindVertexArrayOES(0);
        
        free(vertices);
        free(c);
        free(tex);
        free(el);
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(6, _handle);
    glDeleteVertexArraysOES(1, &_vaoHandle);
}

- (void)updateWithTime:(float)time
{
    if (++_bufferID > 2) {
        _bufferID = 0;
    }
    glBindBuffer(GL_ARRAY_BUFFER, _handle[_bufferID]);
//    Vertex *vertices = (Vertex *)glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    Vertex *vertices = (Vertex *)glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, 0, GL_MAP_WRITE_BIT_EXT);
    generateVertexData(vertices, _sides, _rings, _outerRadius, _innerRadius, time);
    glUnmapBufferOES(GL_ARRAY_BUFFER);
}

- (void)render
{
    glBindVertexArrayOES(_vaoHandle);
    glBindBuffer(GL_ARRAY_BUFFER, _handle[(_bufferID + 1) % 3]);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, position));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, normal));
    glDrawElements(GL_TRIANGLES, 6 * _faces, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
}

+ (void)generateVerts:(Vertex *)verts colors:(GLfloat *)colors
                  tex:(GLfloat *)tex el:(GLuint *)el
          outerRadius:(float)outerRadius innerRadius:(float)innerRadius
                sides:(int)sides rings:(int)rings
{
    float ringFactor = (float)(TWOPI / rings);
    float sideFactor = (float)(TWOPI / sides);
    int tidx = 0, cidx = 0;
    Vertex *pVert = verts;
    for (int ring = 0; ring <= rings; ring++) {
        float u = ring * ringFactor;
        float cu = cos(u);
        float su = sin(u);
        for (int side = 0; side < sides; side++) {
            float v = side * sideFactor;
            float cv = cos(v);
            float sv = sin(v);
            float r = (outerRadius + innerRadius * cv);
            pVert->position.x = r * cu;
            pVert->position.y = r * su;
            pVert->position.z = innerRadius * sv;
            pVert->normal = GLKVector3Normalize(GLKVector3Make(cv * cu * r,
                                                               cv * su * r,
                                                               sv * r));
            pVert += 1;
            tex[tidx] = (float)(u / TWOPI);
            tex[tidx+1] = (float)(v / TWOPI);
            tidx += 2;
            if (ring < rings) {
                colors[cidx] = arc4random() / RAND_MAX;
                colors[cidx + 1] = arc4random() / RAND_MAX;
                colors[cidx + 2] = arc4random() / RAND_MAX;
                colors[cidx + 3] = 1.0;
            } else {
                colors[cidx] = colors[4 * side];
                colors[cidx + 1] = colors[4 * side + 1];
                colors[cidx + 2] = colors[4 * side + 2];
                colors[cidx + 3] = 1.0;
            }
            cidx += 4;
        }
    }

    int idx = 0;
    for (GLuint ring = 0; ring < rings; ring++) {
        int ringStart = ring * sides;
        int nextRingStart = (ring + 1) * sides;
        for (GLuint side = 0; side < sides; side++) {
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

void generateVertexData(Vertex *vertices, int sides, int rings,
                        float outerRadius, float innerRadius, float time)
{
    // Optimize sin/cos with lookup table
    float ringFactor = (float)(TWOPI / rings);
    float sideFactor = (float)(TWOPI / sides);
    Vertex *pVert = vertices;
    float div = innerRadius / 3.0;
    for (int ring = 0; ring <= rings; ring++) {
        float u = ring * ringFactor;
        float cu = cosf(u);
        float su = sinf(u);
        float deformedRadius = innerRadius + sinf(5.0 * u + time) * (su + 0.5) * div;
        for (int side = 0; side < sides; side++) {
            float v = side * sideFactor;
            float cv = cosf(v);
            float sv = sinf(v);
            float r = (outerRadius + deformedRadius * cv);
            pVert->position.x = r * cu;
            pVert->position.y = r * su;
            pVert->position.z = deformedRadius * sv;
            pVert->normal = GLKVector3Normalize(GLKVector3Make(cv * cu * r,
                                                               cv * su * r,
                                                               sv * r));
            pVert += 1;
        }
    }
}
