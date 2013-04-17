//
//  Effect.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "Drawable.h"

@protocol Effect <NSObject>

- (void)prepareToDraw:(id<Drawable>)object;

@end
