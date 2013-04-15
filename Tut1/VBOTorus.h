//
//  VBOTorus.h
//  Tut1
//
//  Created by Evgenij on 4/14/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLKBaseEffect;

@interface VBOTorus : NSObject

- (id)initWithOuterRadius:(float)outerRadius innerRadius:(float)innerRadius nsides:(int) nsides nrings:(int) nrings;
- (void)updateWithTime:(float)time;
- (void)render;

@property (strong, nonatomic) GLKBaseEffect *effect;

@end
