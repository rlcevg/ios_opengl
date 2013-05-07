//
//  FBOShadow.h
//  Tut1
//
//  Created by Evgenij on 4/16/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Effect.h"
#import "Drawable.h"
@class Light, GLSLProgram;

@interface FBOShadow : NSObject <Effect>

- (id)initWithWidth:(GLsizei)width andHeight:(GLsizei)height;
- (void)prepareToDraw;
- (void)prepareToDraw:(id<Drawable>)object;
- (void)process;

+ (GLKMatrix4)shadowBias;

@property (weak, nonatomic) Light *light;
@property (assign, nonatomic, readonly) GLuint name;
@property (assign, nonatomic, readonly) GLenum target;
@property (assign, nonatomic, readonly) GLKVector2 texelSize;

@end
