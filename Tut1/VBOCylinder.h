//
//  VBOCylinder.h
//  Tut1
//
//  Created by Evgenij on 5/6/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Drawable.h"

@interface VBOCylinder : Drawable <Drawable>

- (void)render;

@property (assign, nonatomic) GLKVector3 constantColor;

@end
