//
//  FBOBloom.h
//  Tut1
//
//  Created by Evgenij on 4/29/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBOBloom : NSObject

- (id)initWithScreenWidth:(GLsizei)width andScreenHeight:(GLsizei)height;
- (void)prepareToDraw;
- (void)process;
- (void)render;

@property (assign, nonatomic) GLsizei scrWidth;
@property (assign, nonatomic) GLsizei scrHeight;

@end
