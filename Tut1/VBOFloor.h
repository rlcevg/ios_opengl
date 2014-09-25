//
//  VBOFloor.h
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Drawable.h"

@interface VBOFloor : Drawable <Drawable>

- (id)initWithXsize:(float)xsize zsize:(float)zsize xdivs:(int)xdivs zdivs:(int)zdivs texture:(NSString *)fileName;
- (void)render;

@property (strong, nonatomic, readonly) GLKTextureInfo *texture;
@property (assign, nonatomic) GLKVector3 constColor;

@end
