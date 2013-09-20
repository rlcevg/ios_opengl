//
//  Camera.m
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Camera.h"
#import "ProjectionInfo.h"
#import "ViewInfo.h"
#import "VAOQuad.h"
#import "Effect.h"

#pragma mark

@interface Camera ()

@property (strong, nonatomic) ProjectionInfo *projection;
@property (strong, nonatomic) ViewInfo *view;
@property (strong, nonatomic, readwrite) VAOQuad *farPlaneQuad;

@end

#pragma mark

@implementation Camera

- (id)initWithEye:(GLKVector3)eye center:(GLKVector3)center up:(GLKVector3)up
             fovy:(float)fovy aspect:(float)aspect nearZ:(float)nearZ farZ:(float)farZ
{
    if (self = [super init]) {
        _view = [ViewInfo new];
        _view.eye = eye;
        _view.center = center;
        _view.up = up;
        _projection = [ProjectionInfo new];
        _projection.fovy = fovy;
        _projection.aspect = aspect;
        _projection.nearZ = nearZ;
        _projection.farZ = farZ;
    }
    return self;
}

- (void)dealloc
{
//    self.view = nil;
//    self.projection = nil;
}

- (ViewInfo *)view
{
    if (!_view) {
        _view = [ViewInfo new];
    }
    return _view;
}

- (ProjectionInfo *)projection
{
    if (!_projection) {
        _projection = [ProjectionInfo new];
    }
    return _projection;
}

- (GLKVector3)eye
{
    return self.view.eye;
}

- (void)setEye:(GLKVector3)eye
{
    self.view.eye = eye;
}

- (GLKVector3)center
{
    return self.view.center;
}

- (void)setCenter:(GLKVector3)center
{
    self.view.center = center;
}

- (GLKVector3)up
{
    return self.view.up;
}

- (void)setUp:(GLKVector3)up
{
    self.view.up = up;
}

- (GLKMatrix4)viewMatrix
{
    return self.view.matrix;
}

- (float)fovy
{
    return _projection.fovy;
}

- (void)setFovy:(float)fovy
{
    self.projection.fovy = fovy;
}

- (float)aspect
{
    return self.projection.aspect;
}

- (void)setAspect:(float)aspect
{
    self.projection.aspect = aspect;
}

- (float)nearZ
{
    return self.projection.nearZ;
}

- (void)setNearZ:(float)nearZ
{
    self.projection.nearZ = nearZ;
}

- (float)farZ
{
    return self.projection.farZ;
}

- (void)setFarZ:(float)farZ
{
    self.projection.farZ = farZ;
}

- (GLKMatrix4)projectionMatrix
{
    return self.projection.matrix;
}

- (VAOQuad *)farPlaneQuad
{
    if (!_farPlaneQuad) {
        _farPlaneQuad = [VAOQuad new];
//        MaterialInfo material = {
//            .Ke=GLKVector3Make(0.0f, 0.0f, 0.0f),
//            .Ka=GLKVector3Make(0.035f, 0.025f, 0.015f),
//            .Kd=GLKVector3Make(0.9f, 0.7f, 0.5f),
//            .Ks=GLKVector3Make(1.5f, 1.5f, 1.5f),
//            .shininess=150.0f
//        };
//        _farPlaneQuad.material = material;
        _farPlaneQuad.modelMatrix = GLKMatrix4Identity;
        [self calcFarPlaneQuad];
    }
    else if (self.projection.changed || self.view.changed) {
        [self calcFarPlaneQuad];
    }

    return _farPlaneQuad;
}

- (void)calcFarPlaneQuad
{
    float farDist = self.farZ;
    float heightFar_2 = tanf(self.fovy / 2) * farDist;
    float widthFar_2 = heightFar_2 * self.aspect;
    GLKVector3 dir = GLKVector3Normalize(GLKVector3Subtract(self.center, self.eye));
    GLKVector3 farCenter = GLKVector3Add(self.eye, GLKVector3MultiplyScalar(dir, farDist));
    GLKVector3 up = GLKVector3Normalize(self.up);
    GLKVector3 scaledUp = GLKVector3MultiplyScalar(up, heightFar_2);
    GLKVector3 right = GLKVector3Normalize(GLKVector3CrossProduct(dir, up));
    GLKVector3 scaledRight = GLKVector3MultiplyScalar(right, widthFar_2);

    GLKVector3 tmpAdd = GLKVector3Add(scaledUp, scaledRight);
    GLKVector3 tmpSubstract = GLKVector3Subtract(scaledUp, scaledRight);

    GLKVector3 *data = _farPlaneQuad.data;
    // 0 - bottom left
    data[0] = GLKVector3Subtract(farCenter, tmpAdd);
    // 1 - bottom right
    data[1] = GLKVector3Subtract(farCenter, tmpSubstract);
    // 2 - top left
    data[2] = GLKVector3Add(farCenter, tmpSubstract);
    // 3 - top right
    data[3] = GLKVector3Add(farCenter, tmpAdd);
}

- (void)drawFarPlaneWith:(id<Effect>)effect
{
    VAOQuad *quad = self.farPlaneQuad;
    [effect prepareToDraw:quad];
    [quad render];
}

@end
