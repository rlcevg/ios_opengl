//
//  Drawable.h
//  Tut1
//
//  Created by Evgenij on 4/17/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 Ke; // Emissive light
    GLKVector3 Ka; // Ambient reflectivity
    GLKVector3 Kd; // Diffuse reflectivity
    GLKVector3 Ks; // Specular reflectivity
    float shininess; // Specular shininess factor
} MaterialInfo;

@protocol Drawable <NSObject>

- (void)render;
- (MaterialInfo)material;
- (GLKMatrix4)modelMatrix;

@optional

- (void)update:(float)time;
- (GLKVector3)constantColor;

@end

@interface Drawable : NSObject

@property (assign, nonatomic) MaterialInfo material;
@property (assign, nonatomic) GLKMatrix4 modelMatrix;

@end
