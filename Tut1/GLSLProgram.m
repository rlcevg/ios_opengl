//
//  GLSLProgram.m
//  Tut1
//
//  Created by Evgenij on 4/15/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "GLSLProgram.h"

typedef void (*GLInfoFunction)(GLuint program, GLenum pname, GLint* params);
typedef void (*GLLogFunction)(GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);

#pragma mark

@interface GLSLProgram ()

@property (assign, nonatomic, readwrite) GLuint handle;
@property (assign, nonatomic, readwrite, getter=isLinked) BOOL linked;
@property (strong, nonatomic) NSMutableArray *shaderHandle;

@end

#pragma mark

@implementation GLSLProgram

@synthesize shaderHandle = _shaderHandle;

- (id)init
{
    if (self = [super init]) {
        _shaderHandle = nil;
        _handle = 0;
        _linked = NO;
    }
    return self;
}

- (void)dealloc
{
    [self clear];
    self.shaderHandle = nil;
}

- (NSMutableArray *)shaderHandle
{
    if (!_shaderHandle) {
        _shaderHandle = [NSMutableArray array];
    }
    return _shaderHandle;
}

- (BOOL)loadShaders:(NSString *)name
{
    if (![self compileShader:name type:GL_VERTEX_SHADER]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    if (![self compileShader:name type:GL_FRAGMENT_SHADER]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    glBindAttribLocation(self.handle, GLKVertexAttribPosition, "positionVertex");
    glBindAttribLocation(self.handle, GLKVertexAttribNormal, "normalVertex");
    glBindAttribLocation(self.handle, GLKVertexAttribColor, "colorVertex");
    glBindAttribLocation(self.handle, GLKVertexAttribTexCoord0, "texCoordVertex");

    if (![self link]) {
        NSLog(@"Failed to link program");
        return NO;
    }

    return YES;
}

- (BOOL)compileShader:(NSString *)name type:(GLenum)type
{
    NSString *shaderType;
    switch (type) {
        case GL_VERTEX_SHADER:
            shaderType = @"vsh";
            break;
        case GL_FRAGMENT_SHADER:
            shaderType = @"fsh";
            break;
        default:
            return NO;
    }

    NSString *shaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:shaderType];
    NSError *error;
    NSString *source = [NSString stringWithContentsOfFile:shaderPathname encoding:NSUTF8StringEncoding error:&error];
    if (!source) {
        NSLog(@"Failed to load vertex shader: %@", [error localizedDescription]);
        return NO;
    }

    if (![self compileShaderFromString:[source UTF8String] type:type]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    return YES;
}

- (BOOL)compileShaderFromString:(const GLchar *)source type:(GLenum)type
{
    if (self.handle == 0) {
        self.handle = glCreateProgram();
        if (self.handle == 0) {
            NSLog(@"Unable to create shader program.");
            return NO;
        }
    }

    GLuint shaderHandle = glCreateShader(type);

    glShaderSource(shaderHandle, 1, &source, NULL);
    glCompileShader(shaderHandle);

    GLint status;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &status);
    if (GL_FALSE == status) {
#if defined(DEBUG)
        GLint logLength;
        glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shaderHandle, logLength, &logLength, log);
            NSLog(@"Shader compile log:\n%s", log);
            free(log);
        }
#endif
        glDeleteShader(shaderHandle);
        return NO;
    }

    glAttachShader(self.handle, shaderHandle);
    [self.shaderHandle addObject:[NSNumber numberWithInteger:shaderHandle]];
    return YES;
}

- (BOOL)link
{
    if (self.linked) return YES;
    if (self.handle == 0) return NO;

    glLinkProgram(self.handle);

    GLint status;
    glGetProgramiv(self.handle, GL_LINK_STATUS, &status);
    if (GL_FALSE == status) {
#if defined(DEBUG)
        GLint logLength;
        glGetProgramiv(self.handle, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(self.handle, logLength, &logLength, log);
            NSLog(@"Program link log:\n%s", log);
            free(log);
        }
#endif
        [self clear];
        return NO;
    }

    for (NSNumber *handle in self.shaderHandle) {
        GLuint shader = (GLuint)[handle integerValue];
        glDetachShader(self.handle, shader);
        glDeleteShader(shader);
    }
    [self.shaderHandle removeAllObjects];

    self.linked = YES;
    return YES;
}

- (BOOL)validate
{
    GLint logLength, status;

    glValidateProgram(self.handle);
    glGetProgramiv(self.handle, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(self.handle, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(self.handle, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}

- (void)use
{
    if (self.handle == 0 || !self.linked ) return;
    glUseProgram(self.handle);
}

- (void)bindAttribLocation:(GLuint)location name:(const GLchar *)name
{
    glBindAttribLocation(self.handle, location, name);
}

//- (void)bindFragDataLocation:(GLuint)location name:(const GLchar *)name
//{
//    glBindFragDataLocation(self.handle, location, name);
//}

- (void)setUniform:(const GLchar *)name x:(float)x y:(float)y z:(float)z
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniform3f(loc, x, y, z);
    }
}

- (void)setUniform:(const GLchar *)name vec3:(GLKVector3)v
{
    [self setUniform:name x:v.x y:v.y z:v.z];
}

- (void)setUniform:(const GLchar *)name vec4:(GLKVector4)v
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniform4f(loc, v.x, v.y, v.z, v.w);
    }
}

- (void)setUniform:(const GLchar *)name mat3:(GLKMatrix3)m
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniformMatrix3fv(loc, 1, GL_FALSE, (const GLfloat *)&m);
    }
}

- (void)setUniform:(const GLchar *)name mat4:(GLKMatrix4)m
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniformMatrix4fv(loc, 1, GL_FALSE, (const GLfloat *)&m);
    }
}

- (void)setUniform:(const GLchar *)name valFloat:(float)val
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniform1f(loc, val);
    }
}

- (void)setUniform:(const GLchar *)name valInt:(int)val
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniform1i(loc, val);
    }
}

- (void)setUniform:(const GLchar *)name valBool:(BOOL)val
{
    GLint loc = [self getUniformLocation:name];
    if (loc >= 0) {
        glUniform1i(loc, val);
    }
}

- (void)printActiveUniforms
{
    GLint nUniforms, size, location, maxLen;
    GLchar *name;
    GLsizei written;
    GLenum type;

    glGetProgramiv(self.handle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxLen);
    glGetProgramiv(self.handle, GL_ACTIVE_UNIFORMS, &nUniforms);

    name = (GLchar *)malloc(maxLen);

    NSLog(@" Location | Name");
    NSLog(@"------------------------------------------------");
    for (int i = 0; i < nUniforms; ++i) {
        glGetActiveUniform(self.handle, i, maxLen, &written, &size, &type, name);
        location = glGetUniformLocation(self.handle, name);
        NSLog(@" %-8d | %s", location, name);
    }

    free(name);
}

- (void)printActiveAttribs
{
    GLint written, size, location, maxLength, nAttribs;
    GLenum type;
    GLchar *name;

    glGetProgramiv(self.handle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
    glGetProgramiv(self.handle, GL_ACTIVE_ATTRIBUTES, &nAttribs);

    name = (GLchar *)malloc(maxLength);

    NSLog(@" Index | Name");
    NSLog(@"------------------------------------------------");
    for (int i = 0; i < nAttribs; i++) {
        glGetActiveAttrib(self.handle, i, maxLength, &written, &size, &type, name);
        location = glGetAttribLocation(self.handle, name);
        NSLog(@" %-5d | %s", location, name);
    }

    free(name);
}

- (void)printLog
{
    for (NSNumber *handle in self.shaderHandle) {
        NSLog(@"%@", [self logForOpenGLObject:[handle integerValue]
                                 infoCallback:(GLInfoFunction)&glGetProgramiv
                                      logFunc:(GLLogFunction)&glGetProgramInfoLog]);
    }
    NSLog(@"%@", [self logForOpenGLObject:self.handle
                             infoCallback:(GLInfoFunction)&glGetProgramiv
                                  logFunc:(GLLogFunction)&glGetProgramInfoLog]);
}

- (GLint)getUniformLocation:(const GLchar *)name
{
    return glGetUniformLocation(self.handle, name);
}

- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc
{
    GLint logLength = 0, charsWritten = 0;

    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength < 1)
        return nil;

    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    NSString *log = [[NSString alloc] initWithBytes:logBytes
                                             length:logLength
                                           encoding:NSUTF8StringEncoding];
    free(logBytes);
    return log;
}

- (void)clear
{
    for (NSNumber *handle in self.shaderHandle) {
        GLuint shader = (GLuint)[handle integerValue];
        glDetachShader(self.handle, shader);
        glDeleteShader(shader);
    }
    [self.shaderHandle removeAllObjects];
    if (self.handle) {
        glDeleteProgram(self.handle);
        self.handle = 0;
    }
}

@end
