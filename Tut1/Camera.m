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

#pragma mark

@interface Camera ()

@property (strong, nonatomic) ProjectionInfo *projection;
@property (strong, nonatomic) ViewInfo *view;

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
    self.view = nil;
    self.projection = nil;
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
    ProjectionInfo *projection = self.projection;
    if (aspect != projection.aspect) {
        projection.aspect = aspect;
    }
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

@end
