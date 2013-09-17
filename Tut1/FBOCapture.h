//
//  FBOCapture.h
//  Tut1
//
//  Created by Evgenij on 9/8/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CaptureType {CP_NONE = 0, CP_MSAA} CaptureType;

@interface FBOCapture : NSObject {
@protected
    GLuint _texture;
}

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height;

- (void)prepareToDraw;

@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;
@property (assign, nonatomic, readonly) GLuint texture;
@property (assign, nonatomic, readonly, getter=isChanged) BOOL changed;

+ (FBOCapture *)captureFramebuffer:(CaptureType)type width:(GLsizei)width height:(GLsizei)height;

@end
