//
//  GLSLProgram.h
//  Tut1
//
//  Created by Evgenij on 4/15/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLSLProgram : NSObject

- (id)init;
- (BOOL)loadShaders:(NSString *)name;
- (BOOL)loadShaders:(NSString *)name withAttrs:(NSDictionary *)attrs;
- (BOOL)compileShader:(NSString *)name type:(GLenum)type;
- (BOOL)compileShaderFromString:(const GLchar *)source type:(GLenum)type;
- (BOOL)compileShaderFromFiles:(NSArray *)names type:(GLenum)type;
- (BOOL)compileShaderFromStrings:(const GLchar **)sources num:(int)num type:(GLenum)type;
- (BOOL)link;
- (BOOL)validate;
- (void)use;

// This needs to be done prior to linking.
- (void)bindAttribLocation:(GLuint)location name:(const GLchar *)name;
//- (void)bindFragDataLocation:(GLuint)location name:(const GLchar *)name;
- (GLint)getUniformLocation:(const GLchar *)name;
- (GLint)getAttribLocation:(const GLchar *)name;

- (void)setUniform:(const GLchar *)name x:(float)x y:(float)y z:(float)z;
- (void)setUniform:(const GLchar *)name vec2:(GLKVector2)v;
- (void)setUniform:(const GLchar *)name vec3:(GLKVector3)v;
- (void)setUniform:(const GLchar *)name vec4:(GLKVector4)v;
- (void)setUniform:(const GLchar *)name mat3:(GLKMatrix3)m;
- (void)setUniform:(const GLchar *)name mat4:(GLKMatrix4)m;
- (void)setUniform:(const GLchar *)name valFloat:(float)val;
- (void)setUniform:(const GLchar *)name valInt:(int)val;
- (void)setUniform:(const GLchar *)name valBool:(BOOL)val;

- (void)printActiveUniforms;
- (void)printActiveAttribs;
- (void)printLog;

@property (assign, nonatomic, readonly) GLuint handle;
@property (assign, nonatomic, readonly, getter=isLinked) BOOL linked;

@end
