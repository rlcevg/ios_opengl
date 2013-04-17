//
//  Light.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Camera.h"

@interface Light : Camera

- (id)initWithPosition:(GLKVector4)position center:(GLKVector3)center up:(GLKVector3)up
                  fovy:(float)fovy aspect:(float)aspect nearZ:(float)nearZ farZ:(float)farZ
             intensity:(GLKVector3)intensity;

@property (assign, nonatomic) GLKVector4 position;
@property (assign, nonatomic) GLKVector3 intensity;

@end
