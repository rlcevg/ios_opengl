//
//  FBOCapture.m
//  Tut1
//
//  Created by Evgenij on 9/8/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "FBOCapture.h"
#import "FBOCaptureNone.h"
#import "FBOCaptureMSAA.h"

#pragma mark

@interface FBOCapture ()

@property (assign, nonatomic, readwrite, getter=isChanged) BOOL changed;

@end

#pragma mark

@implementation FBOCapture

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height
{
    if (self = [super init]) {
        _width = width;
        _height = height;
    }
    return self;
}

- (void)setWidth:(GLsizei)width
{
    if (_width != width) {
        _width = width;
        self.changed = YES;
    }
}

- (void)setHeight:(GLsizei)height
{
    if (_height != height) {
        _height = height;
        self.changed = YES;
    }
}

- (void)prepareToDraw
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

+ (FBOCapture *)captureFramebuffer:(CaptureType)type width:(GLsizei)width height:(GLsizei)height
{
    switch (type) {
        case CP_NONE:
        default:
            return [[FBOCaptureNone alloc] initWithWidth:width height:height];

        case CP_MSAA:
            return [[FBOCaptureMSAA alloc] initWithWidth:width height:height];
    }
}

@end
