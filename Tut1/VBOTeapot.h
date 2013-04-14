//
//  VBOTeapot.h
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface VBOTeapot : NSObject

- (id)initWithGrid:(int)grid andLidTransfrom:(GLKMatrix4)lidTransform;
- (void)render;

@end
