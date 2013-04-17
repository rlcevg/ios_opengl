//
//  VBOTeapot.h
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Drawable.h"

@interface VBOTeapot : Drawable <Drawable>

- (id)initWithGrid:(int)grid andLidTransfrom:(GLKMatrix4)lidTransform;
- (void)render;

@property (assign, nonatomic) GLKVector3 constantColor;

@end
