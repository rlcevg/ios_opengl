//
//  FBOBloom.h
//  Tut1
//
//  Created by Evgenij on 4/29/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FBOCapture;

@interface FBOBloom : NSObject

- (id)initWithCaptureFramebuffer:(FBOCapture *)capture;
- (id)initWithWidth:(GLsizei)width height:(GLsizei)height captureFramebuffer:(FBOCapture *)capture;
- (void)prepareToDraw;
- (void)process;
- (void)render;

@property (strong, nonatomic) FBOCapture *capture;

@end
