//
//  VBOFloor.h
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLKBaseEffect;
@class GLKTextureInfo;

@interface VBOFloor : NSObject

- (id)initWithXsize:(float)xsize zsize:(float)zsize xdivs:(int)xdivs zdivs:(int)zdivs texture:(NSString *)fileName;
- (void)render;

@property (strong, nonatomic, readonly) GLKTextureInfo *texture;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end
