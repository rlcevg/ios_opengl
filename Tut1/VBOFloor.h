//
//  VBOFloor.h
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBOFloor : NSObject

- (id)initWithXsize:(float)xsize zsize:(float)zsize xdivs:(int)xdivs zdivs:(int)zdivs;
- (void)render;

@end
