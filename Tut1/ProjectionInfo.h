//
//  ProjectionInfo.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ProjectionInfo : NSObject

@property (assign, nonatomic) float fovy;
@property (assign, nonatomic) float aspect;
@property (assign, nonatomic) float nearZ;
@property (assign, nonatomic) float farZ;
@property (assign, nonatomic) GLKMatrix4 matrix;

@end
