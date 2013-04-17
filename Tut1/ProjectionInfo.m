//
//  ProjectionInfo.m
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "ProjectionInfo.h"

#pragma mark

@interface ProjectionInfo ()

@property (assign, nonatomic, getter=isChanged) BOOL changed;

@end

#pragma mark

@implementation ProjectionInfo

@synthesize fovy = _fovy;
@synthesize aspect = _aspect;
@synthesize nearZ = _nearZ;
@synthesize farZ = _farZ;
@synthesize matrix = _matrix;
@synthesize changed = _changed;

- (id)init
{
    if (self = [super init]) {
        _changed = YES;
    }
    return self;
}

- (void)setFovy:(float)fovy
{
    _fovy = fovy;
    self.changed = YES;
}

- (void)setAspect:(float)aspect
{
    _aspect = aspect;
    self.changed = YES;
}

- (void)setNearZ:(float)nearZ
{
    _nearZ = nearZ;
    self.changed = YES;
}

- (void)setFarZ:(float)farZ
{
    _farZ = farZ;
    self.changed = YES;
}

- (GLKMatrix4)matrix
{
    if (self.changed) {
        _matrix = GLKMatrix4MakePerspective(_fovy, _aspect, _nearZ, _farZ);
        self.changed = NO;
    }
    return _matrix;
}

@end
