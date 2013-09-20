//
//  GLSLBlur.m
//  Tut1
//
//  Created by Evgenij on 9/16/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "GLSLBlur.h"
#import "GLSLProgram.h"

#pragma mark

@interface GLSLBlur ()

@property (strong, nonatomic) GLSLProgram *program;
@property (assign, nonatomic) GLfloat *offsets;
@property (assign, nonatomic) GLfloat *weights;
@property (assign, nonatomic) NSUInteger capacity;

@end

#pragma mark

@implementation GLSLBlur

- (id)init
{
    return [self initWithKernelTaps:KT_17 strength:0.2 scale:1.0];
}

- (id)initWithKernelTaps:(KernelTaps)kernelTaps strength:(float)strength scale:(float)scale
{
    if (self = [super init]) {
        _kernelTaps = kernelTaps;
        _strength = strength;
        _scale = scale;

        [self calcOffsetsWeights];
    }
    return self;
}

- (void)dealloc
{
//    self.program = nil;
    [self clear];
}

- (void)clear
{
    if (self.offsets) {
        free(self.offsets);
//        self.offsets = NULL;
    }
    if (self.weights) {
        free(self.weights);
//        self.weights = NULL;
    }
}

- (GLSLProgram *)program
{
    if (!_program) {
        _program = [GLSLProgram new];
        NSDictionary *attrs = @{
            [NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",
        };
        NSString *shaderName = [NSString stringWithFormat:@"BlurGaussian%d", self.kernelTaps];
        if (![_program loadShaders:shaderName withAttrs:attrs]) {
            [_program printLog];
        }
    }
    return _program;
}

- (void)setKernelTaps:(KernelTaps)kernelTaps
{
    if (_kernelTaps != kernelTaps) {
        _kernelTaps = kernelTaps;
        self.program = nil;
        [self clear];
        [self calcOffsetsWeights];
    }
}

- (void)setStrength:(float)strength
{
    if (_strength != strength) {
        _strength = strength;
        [self clear];
        [self calcOffsetsWeights];
    }
}

- (void)setScale:(float)scale
{
    if (_scale != scale) {
        for (int i = 0; i < self.capacity - 1; ++i) {
            self.offsets[i] /= _scale;
            self.offsets[i] *= scale;
        }
        _scale = scale;
    }
}

- (void)calcOffsetsWeights
{
    NSUInteger capacity = self.capacity = (self.kernelTaps >> 2) + 1;
    self.offsets = (GLfloat *)malloc(sizeof(GLfloat) * (capacity - 1));
    self.weights = (GLfloat *)malloc(sizeof(GLfloat) * capacity);

    NSUInteger discreteCapacity = (self.kernelTaps >> 1) + 1;
    float *discreteWeights = (float *)malloc(sizeof(float) * discreteCapacity);

    float strength = 1.0 - self.strength;
    float deviation = self.kernelTaps * 0.5 * 0.35;
    for (int i = 0; i < discreteCapacity; ++i) {
        discreteWeights[i] = [GLSLBlur gaussianX:(float)i * strength deviation:deviation];
    }

    self.weights[0] = discreteWeights[0];
    for (int i = 1; i < capacity; ++i) {
        float weight = discreteWeights[i * 2] + discreteWeights[i * 2 - 1];
        self.weights[i] = weight;
        float offset = discreteWeights[i * 2] / weight + (i * 2 - 1);
        self.offsets[i - 1] = offset * self.scale;
    }

    free(discreteWeights);
}

- (void)use
{
    GLSLProgram *program = self.program;
    [program use];
    [program setUniform:"offsets" vec:self.offsets count:self.capacity - 1];
    [program setUniform:"weights" vec:self.weights count:self.capacity];
}

- (void)setTexelSize:(GLKVector2)texelSize;
{
    [self.program setUniform:"texelSize" vec2:texelSize];
}

+ (float)gaussianX:(float)x deviation:(float)deviation
{
    return expf(-((x * x) / (2.0 * deviation * deviation))) / (deviation * sqrtf(2.0 * M_PI));
}

@end
