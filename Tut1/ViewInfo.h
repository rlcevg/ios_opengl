//
//  ViewInfo.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ViewInfo : NSObject

@property (assign, nonatomic) GLKVector3 eye;
@property (assign, nonatomic) GLKVector3 center;
@property (assign, nonatomic) GLKVector3 up;
@property (assign, nonatomic) GLKMatrix4 matrix;

@end
