//
//  FBOBloom.m
//  Tut1
//
//  Created by Evgenij on 4/29/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "FBOBloom.h"

#define BUFFER_WIDTH  256
#define BUFFER_HEIGHT 256
#define FILTER_COUNT  3

#pragma mark

GLfloat kernel5[5];

@interface FBOBloom ()

@end

#pragma mark

@implementation FBOBloom

- (id)initWithWidth:(GLsizei)width andHeight:(GLsizei)height
{
    if (self = [super init]) {
//        [self createSurface(pass0, GL_FALSE, GL_FALSE, GL_TRUE);
    }
    return self;
}

+ (float)gaussian:(float)x deviation:(float)deviation
{
    return (1.0 / sqrt(2.0 * 3.141592 * deviation)) * exp(-((x * x) / (2.0 * deviation)));
}

+ (GLfloat *)kernel5
{
    static BOOL calculated = NO;
    if (!calculated) {
        
    }
    return kernel5;
}

@end
