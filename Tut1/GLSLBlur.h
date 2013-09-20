//
//  GLSLBlur.h
//  Tut1
//
//  Created by Evgenij on 9/16/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum KernelTaps {
    KT_5  =  5,
    KT_9  =  9,
    KT_13 = 13,
    KT_17 = 17,
    KT_21 = 21,
    KT_25 = 25
} KernelTaps;

@interface GLSLBlur : NSObject

- (id)initWithKernelTaps:(KernelTaps)kernelTaps strength:(float)strength scale:(float)scale;
- (void)use;
- (void)setTexelSize:(GLKVector2)texelSize;

@property (assign, nonatomic) KernelTaps kernelTaps;
@property (assign, nonatomic) float strength;
@property (assign, nonatomic) float scale;

@end
