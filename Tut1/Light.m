//
//  Light.m
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Light.h"
#import "FBOShadow.h"

#pragma mark

@interface Light ()

@property (strong, nonatomic) FBOShadow *shadow;

@end

#pragma mark

@implementation Light

- (id)initWithPosition:(GLKVector4)position center:(GLKVector3)center up:(GLKVector3)up
                  fovy:(float)fovy aspect:(float)aspect nearZ:(float)nearZ farZ:(float)farZ
             intensity:(GLKVector3)intensity
{
    self = [super initWithEye:GLKVector3Make(position.x, position.y, position.z)
                       center:center up:up fovy:fovy aspect:aspect nearZ:nearZ farZ:farZ];
    if (self) {
        _intensity = intensity;
        _shadow = nil;
    }
    return self;
}

- (void)dealloc
{
//    self.shadow = nil;
}

- (GLKVector4)position
{
    GLKVector3 eye = self.eye;
    return GLKVector4Make(eye.x, eye.y, eye.z, 1.0f);
}

- (void)setPosition:(GLKVector4)position
{
    self.eye = GLKVector3Make(position.x, position.y, position.z);
}

- (FBOShadow *)shadow
{
    if (!_shadow) {
        _shadow = [FBOShadow new];
        _shadow.light = self;
    }
    return _shadow;
}

@end
