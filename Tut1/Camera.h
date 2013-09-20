//
//  Camera.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@class VAOQuad;
@protocol Effect;

@interface Camera : NSObject

- (id)initWithEye:(GLKVector3)eye center:(GLKVector3)center up:(GLKVector3)up
             fovy:(float)fovy aspect:(float)aspect nearZ:(float)nearZ farZ:(float)farZ;
- (void)drawFarPlaneWith:(id<Effect>)effect;

@property (assign, nonatomic) GLKVector3 eye;
@property (assign, nonatomic) GLKVector3 center;
@property (assign, nonatomic) GLKVector3 up;
@property (assign, nonatomic, readonly) GLKMatrix4 viewMatrix;
@property (assign, nonatomic) float fovy;
@property (assign, nonatomic) float aspect;
@property (assign, nonatomic) float nearZ;
@property (assign, nonatomic) float farZ;
@property (assign, nonatomic, readonly) GLKMatrix4 projectionMatrix;
@property (strong, nonatomic, readonly) VAOQuad *farPlaneQuad;

@end
