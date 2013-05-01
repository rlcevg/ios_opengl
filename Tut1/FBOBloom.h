//
//  FBOBloom.h
//  Tut1
//
//  Created by Evgenij on 4/29/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBOBloom : NSObject

- (id)initWithWidth:(GLsizei)width andHeight:(GLsizei)height;

+ (GLfloat *)kernel5;

@end
