//
//  VAOQuad.h
//  Tut1
//
//  Created by Evgenij on 9/19/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Drawable.h"

@interface VAOQuad : Drawable <Drawable>

- (void)render;

@property (assign, nonatomic, readonly) GLKVector3 *data;

@end
