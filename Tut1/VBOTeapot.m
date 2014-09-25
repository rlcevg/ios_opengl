//
//  VBOTeapot.m
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "VBOTeapot.h"
#import "Utils.h"

static const int Teapot_patchdata[][16] =
{
    /* rim */
    {102, 103, 104, 105, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
    /* body */
    {12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27},
    {24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40},
    /* lid */
    {96, 96, 96, 96, 97, 98, 99, 100, 101, 101, 101, 101, 0, 1, 2, 3,},
    {0, 1, 2, 3, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117},
    /* bottom */
    {118, 118, 118, 118, 124, 122, 119, 121, 123, 126, 125, 120, 40, 39, 38, 37},
    /* handle */
    {41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56},
    {53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 28, 65, 66, 67},
    /* spout */
    {68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83},
    {80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95}
};

static const float Teapot_cpdata[][3] =
{
    {0.2, 0, 2.7},
    {0.2, -0.112, 2.7},
    {0.112, -0.2, 2.7},
    {0, -0.2, 2.7},
    {1.3375, 0, 2.53125},
    {1.3375, -0.749, 2.53125},
    {0.749, -1.3375, 2.53125},
    {0, -1.3375, 2.53125},
    {1.4375, 0, 2.53125},
    {1.4375, -0.805, 2.53125},
    {0.805, -1.4375, 2.53125},
    {0, -1.4375, 2.53125},
    {1.5, 0, 2.4},
    {1.5, -0.84, 2.4},
    {0.84, -1.5, 2.4},
    {0, -1.5, 2.4},
    {1.75, 0, 1.875},
    {1.75, -0.98, 1.875},
    {0.98, -1.75, 1.875},
    {0, -1.75, 1.875},
    {2, 0, 1.35},
    {2, -1.12, 1.35},
    {1.12, -2, 1.35},
    {0, -2, 1.35},
    {2, 0, 0.9},
    {2, -1.12, 0.9},
    {1.12, -2, 0.9},
    {0, -2, 0.9},
    {-2, 0, 0.9},
    {2, 0, 0.45},
    {2, -1.12, 0.45},
    {1.12, -2, 0.45},
    {0, -2, 0.45},
    {1.5, 0, 0.225},
    {1.5, -0.84, 0.225},
    {0.84, -1.5, 0.225},
    {0, -1.5, 0.225},
    {1.5, 0, 0.15},
    {1.5, -0.84, 0.15},
    {0.84, -1.5, 0.15},
    {0, -1.5, 0.15},
    {-1.6, 0, 2.025},
    {-1.6, -0.3, 2.025},
    {-1.5, -0.3, 2.25},
    {-1.5, 0, 2.25},
    {-2.3, 0, 2.025},
    {-2.3, -0.3, 2.025},
    {-2.5, -0.3, 2.25},
    {-2.5, 0, 2.25},
    {-2.7, 0, 2.025},
    {-2.7, -0.3, 2.025},
    {-3, -0.3, 2.25},
    {-3, 0, 2.25},
    {-2.7, 0, 1.8},
    {-2.7, -0.3, 1.8},
    {-3, -0.3, 1.8},
    {-3, 0, 1.8},
    {-2.7, 0, 1.575},
    {-2.7, -0.3, 1.575},
    {-3, -0.3, 1.35},
    {-3, 0, 1.35},
    {-2.5, 0, 1.125},
    {-2.5, -0.3, 1.125},
    {-2.65, -0.3, 0.9375},
    {-2.65, 0, 0.9375},
    {-2, -0.3, 0.9},
    {-1.9, -0.3, 0.6},
    {-1.9, 0, 0.6},
    {1.7, 0, 1.425},
    {1.7, -0.66, 1.425},
    {1.7, -0.66, 0.6},
    {1.7, 0, 0.6},
    {2.6, 0, 1.425},
    {2.6, -0.66, 1.425},
    {3.1, -0.66, 0.825},
    {3.1, 0, 0.825},
    {2.3, 0, 2.1},
    {2.3, -0.25, 2.1},
    {2.4, -0.25, 2.025},
    {2.4, 0, 2.025},
    {2.7, 0, 2.4},
    {2.7, -0.25, 2.4},
    {3.3, -0.25, 2.4},
    {3.3, 0, 2.4},
    {2.8, 0, 2.475},
    {2.8, -0.25, 2.475},
    {3.525, -0.25, 2.49375},
    {3.525, 0, 2.49375},
    {2.9, 0, 2.475},
    {2.9, -0.15, 2.475},
    {3.45, -0.15, 2.5125},
    {3.45, 0, 2.5125},
    {2.8, 0, 2.4},
    {2.8, -0.15, 2.4},
    {3.2, -0.15, 2.4},
    {3.2, 0, 2.4},
    {0, 0, 3.15},
    {0.8, 0, 3.15},
    {0.8, -0.45, 3.15},
    {0.45, -0.8, 3.15},
    {0, -0.8, 3.15},
    {0, 0, 2.85},
    {1.4, 0, 2.4},
    {1.4, -0.784, 2.4},
    {0.784, -1.4, 2.4},
    {0, -1.4, 2.4},
    {0.4, 0, 2.55},
    {0.4, -0.224, 2.55},
    {0.224, -0.4, 2.55},
    {0, -0.4, 2.55},
    {1.3, 0, 2.55},
    {1.3, -0.728, 2.55},
    {0.728, -1.3, 2.55},
    {0, -1.3, 2.55},
    {1.3, 0, 2.4},
    {1.3, -0.728, 2.4},
    {0.728, -1.3, 2.4},
    {0, -1.3, 2.4},
    {0, 0, 0},
    {1.425, -0.798, 0},
    {1.5, 0, 0.075},
    {1.425, 0, 0},
    {0.798, -1.425, 0},
    {0, -1.5, 0.075},
    {0, -1.425, 0},
    {1.5, -0.84, 0.075},
    {0.84, -1.5, 0.075}
};

void generatePatches(GLfloat * v, GLfloat * n, GLfloat *tc, GLuint *el, int grid);
void buildPatchReflect(int patchNum,
                       float *B, float *dB,
                       GLfloat *v, GLfloat *n, GLfloat *tc, GLuint *el,
                       int *index, int *elIndex, int *tcIndex, int grid,
                       bool reflectX, bool reflectY);
void buildPatch(GLKVector3 patch[][4],
                float *B, float *dB,
                GLfloat *v, GLfloat *n, GLfloat *tc, GLuint *el,
                int *index, int *elIndex, int *tcIndex, int grid, GLKMatrix3 reflect, bool invertNormal);
void getPatch(int patchNum, GLKVector3 patch[][4], bool reverseV);
void computeBasisFunctions(float *B, float *dB, int grid);
GLKVector3 evaluate(int gridU, int gridV, float *B, GLKVector3 patch[][4]);
GLKVector3 evaluateNormal(int gridU, int gridV, float *B, float *dB, GLKVector3 patch[][4]);
void moveLid(int grid, GLfloat *v, GLKMatrix4 lidTransform);

#pragma mark - private declarations

@interface VBOTeapot () {
    GLuint _vaoHandle;
    GLuint _handle[4];
    unsigned int _faces;
}

@end

#pragma mark

@implementation VBOTeapot

- (id)init
{
//    [self release];  // ARC constraint
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                        reason:@"-init is not a valid initializer for the class VBOTeapot"
                        userInfo:nil];
    return nil;
}

- (id)initWithGrid:(int)grid lidTransfrom:(GLKMatrix4)lidTransform
{
    if (self = [super init]) {
        int verts = 32 * (grid + 1) * (grid + 1);
        _faces = grid * grid * 32;
        GLfloat *v = (GLfloat *)malloc(sizeof(GLfloat) * verts * 3);
        GLfloat *n = (GLfloat *)malloc(sizeof(GLfloat) * verts * 3);
        GLfloat *tc = (GLfloat *)malloc(sizeof(GLfloat) * verts * 2);
        GLuint *el = (GLuint *)malloc(sizeof(GLuint) * _faces * 6);

        glGenVertexArraysOES(1, &_vaoHandle);
        glBindVertexArrayOES(_vaoHandle);

        glGenBuffers(4, _handle);

        generatePatches(v, n, tc, el, grid);
        moveLid(grid, v, lidTransform);

        glBindBuffer(GL_ARRAY_BUFFER, _handle[0]);
        glBufferData(GL_ARRAY_BUFFER, (3 * verts) * sizeof(GLfloat), v, GL_STATIC_DRAW);
        glVertexAttribPointer((GLuint)0, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(0);  // Vertex position

        glBindBuffer(GL_ARRAY_BUFFER, _handle[1]);
        glBufferData(GL_ARRAY_BUFFER, (3 * verts) * sizeof(GLfloat), n, GL_STATIC_DRAW);
        glVertexAttribPointer((GLuint)1, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(1);  // Vertex normal

        glBindBuffer(GL_ARRAY_BUFFER, _handle[2]);
        glBufferData(GL_ARRAY_BUFFER, (2 * verts) * sizeof(GLfloat), tc, GL_STATIC_DRAW);
        glVertexAttribPointer((GLuint)3, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(3);  // texture coords

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _handle[3]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * _faces * sizeof(GLuint), el, GL_STATIC_DRAW);
        
        glBindVertexArrayOES(0);

        free(v);
        free(n);
        free(el);
        free(tc);
    }
    return self;
}

- (void)dealloc
{
	glDeleteBuffers(4, _handle);
	glDeleteVertexArraysOES(1, &_vaoHandle);
}

- (void)render
{
    glDisable(GL_CULL_FACE);
    glBindVertexArrayOES(_vaoHandle);
    glDrawElements(GL_TRIANGLES, 6 * _faces, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    glEnable(GL_CULL_FACE);
}

@end

void generatePatches(GLfloat *v, GLfloat *n, GLfloat *tc, GLuint *el, int grid)
{
    float *B = (float *)malloc(sizeof(float) * 4 * (grid + 1));  // Pre-computed Bernstein basis functions
    float *dB = (float *)malloc(sizeof(float) * 4 * (grid + 1)); // Pre-computed derivitives of basis functions

    int idx = 0, elIndex = 0, tcIndex = 0;

    // Pre-compute the basis functions  (Bernstein polynomials)
    // and their derivatives
    computeBasisFunctions(B, dB, grid);

    // Build each patch
    // The rim
    buildPatchReflect(0, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, true, true);
    // The body
    buildPatchReflect(1, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, true, true);
    buildPatchReflect(2, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, true, true);
    // The lid
    buildPatchReflect(3, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, true, true);
    buildPatchReflect(4, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, true, true);
    // The bottom
    buildPatchReflect(5, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, true, true);
    // The handle
    buildPatchReflect(6, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, false, true);
    buildPatchReflect(7, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, false, true);
    // The spout
    buildPatchReflect(8, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, false, true);
    buildPatchReflect(9, B, dB, v, n, tc, el, &idx, &elIndex, &tcIndex, grid, false, true);

    free(B);
    free(dB);
}

void moveLid(int grid, GLfloat *v, GLKMatrix4 lidTransform)
{
    int start = 3 * 12 * (grid + 1) * (grid + 1);
    int end = 3 * 20 * (grid + 1) * (grid + 1);

    for (int i = start; i < end; i += 3)
    {
        GLKVector4 vert = GLKVector4Make(v[i], v[i + 1], v[i + 2], 1.0f);
        vert = GLKMatrix4MultiplyVector4(lidTransform, vert);
        v[i] = vert.x;
        v[i + 1] = vert.y;
        v[i + 2] = vert.z;
    }
}

void buildPatchReflect(int patchNum,
                       float *B, float *dB,
                       GLfloat *v, GLfloat *n,
                       GLfloat *tc, GLuint *el,
                       int *index, int *elIndex, int *tcIndex, int grid,
                       bool reflectX, bool reflectY)
{
    GLKVector3 patch[4][4];
    GLKVector3 patchRevV[4][4];
    getPatch(patchNum, patch, false);
    getPatch(patchNum, patchRevV, true);

    // Patch without modification
    buildPatch(patch, B, dB, v, n, tc, el,
               index, elIndex, tcIndex, grid, GLKMatrix3Identity, true);

    // Patch reflected in x
    if (reflectX) {
        buildPatch(patchRevV, B, dB, v, n, tc, el,
                   index, elIndex, tcIndex, grid, GLKMatrix3Make(-1.0f, 0.0f, 0.0f,
                                                                 0.0f, 1.0f, 0.0f,
                                                                 0.0f, 0.0f, 1.0f), false);
    }

    // Patch reflected in y
    if (reflectY) {
        buildPatch(patchRevV, B, dB, v, n, tc, el,
                   index, elIndex, tcIndex, grid, GLKMatrix3Make(1.0f, 0.0f, 0.0f,
                                                                 0.0f, -1.0f, 0.0f,
                                                                 0.0f, 0.0f, 1.0f), false);
    }

    // Patch reflected in x and y
    if (reflectX && reflectY) {
        buildPatch(patch, B, dB, v, n, tc, el,
                   index, elIndex, tcIndex, grid, GLKMatrix3Make(-1.0f, 0.0f, 0.0f,
                                                                 0.0f, -1.0f, 0.0f,
                                                                 0.0f, 0.0f, 1.0f), true);
    }
}

void buildPatch(GLKVector3 patch[][4],
                float *B, float *dB,
                GLfloat *v, GLfloat *n, GLfloat *tc,
                GLuint *el,
                int *index, int *elIndex, int *tcIndex, int grid, GLKMatrix3 reflect,
                bool invertNormal)
{
    int idx, elIdx, tcIdx;
    int startIndex = *index / 3;
    float tcFactor = 1.0f / grid;

    for (int i = 0; i <= grid; i++)
    {
        for (int j = 0 ; j <= grid; j++)
        {
            GLKVector3 pt = GLKMatrix3MultiplyVector3(reflect, evaluate(i, j, B, patch));
            GLKVector3 norm = GLKMatrix3MultiplyVector3(reflect, evaluateNormal(i, j, B, dB, patch));
            if (invertNormal)
                norm = GLKVector3Negate(norm);

            idx = *index;
            v[idx] = pt.x;
            v[idx + 1] = pt.y;
            v[idx + 2] = pt.z;

            n[idx] = norm.x;
            n[idx + 1] = norm.y;
            n[idx + 2] = norm.z;

            tcIdx = *tcIndex;
            tc[tcIdx] = i * tcFactor;
            tc[tcIdx + 1] = j * tcFactor;

            *index += 3;
            *tcIndex += 2;
        }
    }

    for (GLuint i = 0; i < grid; i++)
    {
        int iStart = i * (grid+1) + startIndex;
        int nextiStart = (i+1) * (grid+1) + startIndex;
        for (GLuint j = 0; j < grid; j++)
        {
            elIdx = *elIndex;
            el[elIdx] = iStart + j;
            el[elIdx + 1] = nextiStart + j + 1;
            el[elIdx + 2] = nextiStart + j;

            el[elIdx + 3] = iStart + j;
            el[elIdx + 4] = iStart + j + 1;
            el[elIdx + 5] = nextiStart + j + 1;

            *elIndex += 6;
        }
    }
}

void getPatch(int patchNum, GLKVector3 patch[][4], bool reverseV)
{
    for (int u = 0; u < 4; u++) {          // Loop in u direction
        for (int v = 0; v < 4; v++) {      // Loop in v direction
            if (reverseV) {
                patch[u][v] = GLKVector3Make(
                                   Teapot_cpdata[Teapot_patchdata[patchNum][u * 4 + (3 - v)]][0],
                                   Teapot_cpdata[Teapot_patchdata[patchNum][u * 4 + (3 - v)]][1],
                                   Teapot_cpdata[Teapot_patchdata[patchNum][u * 4 + (3 - v)]][2]
                                   );
            } else {
                patch[u][v] = GLKVector3Make(
                                   Teapot_cpdata[Teapot_patchdata[patchNum][u * 4 + v]][0],
                                   Teapot_cpdata[Teapot_patchdata[patchNum][u * 4 + v]][1],
                                   Teapot_cpdata[Teapot_patchdata[patchNum][u * 4 + v]][2]
                                   );
            }
        }
    }
}

void computeBasisFunctions(float * B, float * dB, int grid)
{
    float inc = 1.0f / grid;
    for (int i = 0; i <= grid; i++)
    {
        float t = i * inc;
        float tSqr = t * t;
        float oneMinusT = (1.0f - t);
        float oneMinusT2 = oneMinusT * oneMinusT;

        B[i * 4 + 0] = oneMinusT * oneMinusT2;
        B[i * 4 + 1] = 3.0f * oneMinusT2 * t;
        B[i * 4 + 2] = 3.0f * oneMinusT * tSqr;
        B[i * 4 + 3] = t * tSqr;

        dB[i * 4 + 0] = -3.0f * oneMinusT2;
        dB[i * 4 + 1] = -6.0f * t * oneMinusT + 3.0f * oneMinusT2;
        dB[i * 4 + 2] = -3.0f * tSqr + 6.0f * t * oneMinusT;
        dB[i * 4 + 3] = 3.0f * tSqr;
    }
}


GLKVector3 evaluate(int gridU, int gridV, float *B, GLKVector3 patch[][4])
{
    GLKVector3 p = {0.0f, 0.0f, 0.0f};
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            p = GLKVector3Add(p, GLKVector3MultiplyScalar(patch[i][j], B[gridU * 4 + i] * B[gridV * 4 + j]));
        }
    }
    return p;
}

GLKVector3 evaluateNormal(int gridU, int gridV, float *B, float *dB, GLKVector3 patch[][4])
{
    GLKVector3 du = {0.0f, 0.0f, 0.0f};
    GLKVector3 dv = {0.0f, 0.0f, 0.0f};

    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            du = GLKVector3Add(du, GLKVector3MultiplyScalar(patch[i][j], dB[gridU * 4 + i] * B[gridV * 4 + j]));
            dv = GLKVector3Add(dv, GLKVector3MultiplyScalar(patch[i][j], B[gridU * 4 + i] * dB[gridV * 4 + j]));
        }
    }
    return GLKVector3Normalize(GLKVector3CrossProduct(du, dv));
}
