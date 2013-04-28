//
//  SceneEffect.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Effect.h"
#import "Drawable.h"
@class Light, Camera;

@interface SceneEffect : NSObject <Effect>

- (void)prepareToDraw;
- (void)prepareToDraw:(id<Drawable>)object;

@property (weak, nonatomic) Light *light;
@property (weak, nonatomic) Camera *camera;

@end
