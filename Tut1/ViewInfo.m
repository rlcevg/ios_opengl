//
//  ViewInfo.m
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "ViewInfo.h"

#pragma mark

@interface ViewInfo ()

@property (assign, nonatomic, getter=isChanged) BOOL changed;

@end

#pragma mark

@implementation ViewInfo

@synthesize eye = _eye;
@synthesize center = _center;
@synthesize up = _up;
@synthesize matrix = _matrix;
@synthesize changed = _changed;

- (id)init
{
    if (self = [super init]) {
        _changed = YES;
    }
    return self;
}

- (void)setEye:(GLKVector3)eye
{
    _eye = eye;
    self.changed = YES;
}

- (void)setCenter:(GLKVector3)center
{
    _center = center;
    self.changed = YES;
}

- (void)setUp:(GLKVector3)up
{
    _up = up;
    self.changed = YES;
}

- (GLKMatrix4)matrix
{
    if (self.changed) {
        _matrix = GLKMatrix4MakeLookAt(_eye.x, _eye.y, _eye.z,
                                       _center.x, _center.y, _center.y,
                                       _up.x, _up.y, _up.z);
        self.changed = NO;
    }
    return _matrix;
}

@end
