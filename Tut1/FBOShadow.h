//
//  FBOShadow.h
//  Tut1
//
//  Created by Evgenij on 4/16/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Effect.h"
#import "Drawable.h"
@class Light;

@interface FBOShadow : NSObject <Effect>

- (id)initWithWidth:(GLsizei)width andHeight:(GLsizei)height;
- (void)prepareToDraw:(id<Drawable>)object;

+ (GLKMatrix4)shadowBias;

@property (weak, nonatomic) Light *light;
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;
@property (assign, nonatomic, readonly) GLuint depthTex;
@property (assign, nonatomic, readonly) GLuint colorTex;
@property (assign, nonatomic, readonly) GLuint handle;

@end
