//
//  TUTViewController.m
//  Tut1
//
//  Created by Evgenij on 4/11/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import "TUTViewController.h"
#import "VBOTeapot.h"
#import "VBOFloor.h"
#import "VBOTorus.h"
#import "VBOCylinder.h"
#import "Camera.h"
#import "Light.h"
#import "FBOShadow.h"
#import "SceneEffect.h"
#import "FBOCapture.h"
#import "FBOBloom.h"
#import <OpenGLES/ES2/glext.h>

//#ifdef DEBUG
//#import "VBOScreenQuad.h"
//#import "GLSLProgram.h"
//#endif

#pragma mark

@interface TUTViewController () {
    float _rotation;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@property (strong, nonatomic) VBOTeapot *teapot;
@property (strong, nonatomic) VBOFloor *floor;
@property (strong, nonatomic) VBOTorus *torus;
@property (strong, nonatomic) VBOCylinder *cylinder;
@property (strong, nonatomic) Camera *camera;
@property (strong, nonatomic) Light *light;
@property (strong, nonatomic) SceneEffect *sceneEffect;
@property (strong, nonatomic) FBOCapture *capture;
@property (strong, nonatomic) FBOBloom *bloom;
@property (assign, nonatomic) BOOL bloomEnabled;
@property (assign, nonatomic) BOOL torusEnabled;
@property (strong, nonatomic) GLKTextureInfo *cubemap;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;

@end

#pragma mark

@implementation TUTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.preferredFramesPerSecond = 60;

    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
//    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

#ifdef DEBUG
    NSString *extensionString = [NSString stringWithUTF8String:(char *)glGetString(GL_EXTENSIONS)];
    NSArray *extensions = [extensionString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString *oneExtension in extensions) {
        NSLog(@"%@", oneExtension);
    }

    // NOTE: ES3+ only
//    int max = 0;
//    glGetIntegerv(GL_NUM_EXTENSIONS, &max);
//    for (int i = 0; i < max; i++) {
//        NSLog(@"%s", glGetStringi(GL_EXTENSIONS, i));
//    }
#endif

    NSArray *cubeMapFileNames = [NSArray arrayWithObjects:
                                 [[NSBundle mainBundle] pathForResource:@"rightsp9" ofType:@"jpg"],
                                 [[NSBundle mainBundle] pathForResource:@"leftsp9"  ofType:@"jpg"],
                                 [[NSBundle mainBundle] pathForResource:@"topsp9"   ofType:@"jpg"],
                                 [[NSBundle mainBundle] pathForResource:@"botsp9"   ofType:@"jpg"],
                                 [[NSBundle mainBundle] pathForResource:@"frontsp9" ofType:@"jpg"],
                                 [[NSBundle mainBundle] pathForResource:@"backsp9"  ofType:@"jpg"],
                                 nil];
    NSError *error;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:GLKTextureLoaderOriginBottomLeft];
    self.cubemap = [GLKTextureLoader cubeMapWithContentsOfFiles:cubeMapFileNames
                                                        options:options
                                                          error:&error];
    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    self.skyboxEffect.textureCubeMap.name = self.cubemap.name;

    self.sceneEffect = [SceneEffect new];
    self.light = [[Light alloc] initWithPosition:GLKVector4Make(-5.0f, 7.0f, 5.0f, 1.0f)
                                          center:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                              up:GLKVector3Make(0.0f, 1.0f, 0.0f)
                                            fovy:GLKMathDegreesToRadians(65.0f)
                                          aspect:2.0f nearZ:1.0f farZ:20.0f
                                       intensity:GLKVector3Make(1.0f, 1.0f, 1.0f)];

    MaterialInfo material = {
        .Ke=GLKVector3Make(0.0f, 0.0f, 0.0f),
        .Ka=GLKVector3Make(0.035f, 0.025f, 0.015f),
        .Kd=GLKVector3Make(0.9f, 0.7f, 0.5f),
        .Ks=GLKVector3Make(1.5f, 1.5f, 1.5f),
        .shininess=150.0f
    };
    self.teapot = [[VBOTeapot alloc] initWithGrid:14 lidTransfrom:GLKMatrix4Identity];
    self.teapot.material = material;
    self.teapot.constColor = GLKVector3Make(0.7f, 0.8f, 0.2f);
    self.floor = [VBOFloor new];
    material.Ks = GLKVector3Make(0.2f, 0.2f, 0.2f);
    material.shininess = 10.0f;
    self.floor.material = material;
    self.floor.constColor = GLKVector3Make(0.8f, 0.8f, 0.8f);
    self.torus = [VBOTorus new];
    material.Ks = GLKVector3Make(5.5f, 7.5f, 9.5f);
    material.Ke = GLKVector3Make(0.1f, 0.1f, 0.3f);
    material.shininess = 100.0f;
    self.torus.material = material;
    self.torusEnabled = self.torusSwitch.on;
    self.bloomEnabled = self.bloomSwitch.on;
    self.cylinder = [VBOCylinder new];
    self.cylinder.material = material;

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    self.camera = [[Camera alloc] initWithEye:GLKVector3Make(-1.0f, 7.0f, 5.0f)
                                       center:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                           up:GLKVector3Make(0.0f, 1.0f, 0.0f)
                                         fovy:GLKMathDegreesToRadians(65.0f) aspect:aspect
                                        nearZ:0.1f farZ:50.0f];

    CGSize screenSize = self.view.bounds.size;
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    self.capture = [FBOCapture captureFramebuffer:self.msaaSwitch.on ? CP_MSAA : CP_NONE
                                            width:screenSize.width * screenScale
                                           height:screenSize.height * screenScale];
    self.bloom = [[FBOBloom alloc] initWithCaptureFramebuffer:self.capture];

    glClearColor(0.35f, 0.65f, 0.79f, 1.0f);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    self.camera = nil;
    self.light = nil;

    self.teapot = nil;
    self.floor = nil;
    self.torus = nil;

    self.sceneEffect = nil;
    self.bloom = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    self.camera.aspect = aspect;

    CGSize screenSize = self.view.bounds.size;
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    self.capture.width = screenSize.width * screenScale;
    self.capture.height = screenSize.height * screenScale;

    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    self.floor.modelMatrix = modelMatrix;

    modelMatrix = GLKMatrix4MakeTranslation(-2.0f, 4.0f, 2.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    self.torus.modelMatrix = modelMatrix;

    // Compute the model view matrix for the object rendered with ES2
    modelMatrix = GLKMatrix4MakeTranslation(1.0f, 0.0f, -1.0f);
    modelMatrix = GLKMatrix4RotateY(modelMatrix, _rotation);
    modelMatrix = GLKMatrix4RotateX(modelMatrix, GLKMathDegreesToRadians(-90.0f));
    self.teapot.modelMatrix = modelMatrix;

    modelMatrix = GLKMatrix4MakeTranslation(3.0f, 2.0f, 2.0f);
    modelMatrix = GLKMatrix4RotateX(modelMatrix, GLKMathDegreesToRadians(90.0f));
    self.cylinder.modelMatrix = modelMatrix;

//    GLKMatrix3 rotate = GLKMatrix3MakeRotation(self.timeSinceLastUpdate * 4, -4.0f, 7.0f, 4.0f);
//    self.light.eye = GLKMatrix3MultiplyVector3(rotate, self.light.eye);

    _rotation += self.timeSinceLastUpdate * 0.5f;

    [self.torus updateWithTime:_rotation * 10];

    self.skyboxEffect.transform.projectionMatrix = self.camera.projectionMatrix;
    modelMatrix = GLKMatrix4Scale(self.camera.viewMatrix, 40, 40, 40);
    self.skyboxEffect.transform.modelviewMatrix = GLKMatrix4RotateY(modelMatrix, -(M_PI + 1.0));
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    static VBOScreenQuad *quad = nil;
//    if (!quad) {
//        quad = [VBOScreenQuad screenQuad];
//    }
//    static GLSLProgram *program = nil;
//    if (!program) {
//        program = [[GLSLProgram alloc] init];
//        [program loadShaders:@"Debug" withAttrs:@{[NSNumber numberWithInteger:GLKVertexAttribTexCoord0] : @"texCoordVertex",}];
//    }

    CFTimeInterval previousTimestamp = CFAbsoluteTimeGetCurrent();

    // Pass 1 (shadow map generation)
    [self.light.shadow prepareToDraw];
    [self renderWith:self.light.shadow];
//    [self.light drawFarPlaneWith:self.light.shadow];
    [self.light.shadow process];

//    [(GLKView *)self.view bindDrawable];
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glBindTexture(GL_TEXTURE_2D, self.light.shadow.name);
//    [program use];
//    [quad render];

    // Pass 2 (render)
    self.sceneEffect.light = self.light;
    self.sceneEffect.camera = self.camera;
    [self.sceneEffect prepareToDraw];

    if (self.bloomEnabled) {
        [self.bloom prepareToDraw];

        [self.skyboxEffect prepareToDraw];
        [self.skyboxEffect draw];

        [self renderWith:self.sceneEffect];
        [self.bloom process];
        [(GLKView *)self.view bindDrawable];
        [self.bloom render];

    } else {
        [(GLKView *)self.view bindDrawable];
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        [self.skyboxEffect prepareToDraw];
        [self.skyboxEffect draw];

        [self renderWith:self.sceneEffect];
    }

//    glUseProgram(0);

//    glFinish();
    CFTimeInterval curTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval frameDuration = curTime - previousTimestamp;
    static CFTimeInterval totalDuration = 0;
    static unsigned totalFrames = 0;
    static CFTimeInterval lastTime = 0;
    totalDuration += frameDuration;
    totalFrames++;
    if (curTime - lastTime > 2.0) {
        self.labelFPS.text = [NSString stringWithFormat:@"%.2f", totalFrames / totalDuration];
        lastTime = curTime;
        totalDuration = 0;
        totalFrames = 0;
    }
}

- (void)renderWith:(id<Effect>)effect
{
    // TODO: Sort objects in Z-order
    [effect prepareToDraw:self.teapot];
    [self.teapot render];
    if (self.torusEnabled) {
        [effect prepareToDraw:self.torus];
        [self.torus render];
    }
    [effect prepareToDraw:self.floor];
    [self.floor render];
    [effect prepareToDraw:self.cylinder];
    [self.cylinder render];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    self.paused = !self.paused;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];

    GLKMatrix4 viewProjectionMatrix = GLKMatrix4Multiply(self.camera.projectionMatrix, self.camera.viewMatrix);
    GLKMatrix4 unproject = GLKMatrix4Invert(viewProjectionMatrix, NULL);
    GLKVector4 new_trans = GLKVector4Make(-translation.x, translation.y, 0.0, 1.0);
    GLKVector4 new_eye4 = GLKMatrix4MultiplyVector4(unproject, new_trans);
    GLKVector3 new_eye = GLKVector3Make(new_eye4.x, new_eye4.y, new_eye4.z);
    GLKVector3 rotor = GLKVector3CrossProduct(self.camera.eye, new_eye);
    if (rotor.x == 0.0 && rotor.y == 0.0 && rotor.z == 0.0) {
        rotor.y = 1.0;
    }
    GLKMatrix3 rotate = GLKMatrix3MakeRotation(GLKMathDegreesToRadians(sqrtf(translation.x * translation.x + translation.y * translation.y)),
                                               rotor.x, rotor.y, rotor.z);
    self.camera.eye = GLKMatrix3MultiplyVector3(rotate, self.camera.eye);

    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)switchMSAA:(UISwitch *)sender
{
    if (sender.on) {
        if (self.bloomEnabled) {
            CGSize screenSize = self.view.bounds.size;
            CGFloat screenScale = [[UIScreen mainScreen] scale];
            self.capture = [FBOCapture captureFramebuffer:CP_MSAA
                                                    width:screenSize.width * screenScale
                                                   height:screenSize.height * screenScale];
            self.bloom.capture = self.capture;
        } else {
            ((GLKView *)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
        }
    } else {
        if (self.bloomEnabled) {
            CGSize screenSize = self.view.bounds.size;
            CGFloat screenScale = [[UIScreen mainScreen] scale];
            self.capture = [FBOCapture captureFramebuffer:CP_NONE
                                                    width:screenSize.width * screenScale
                                                   height:screenSize.height * screenScale];
            self.bloom.capture = self.capture;
        } else {
            ((GLKView *)self.view).drawableMultisample = GLKViewDrawableMultisampleNone;
        }
    }
}

- (IBAction)switchTorus:(UISwitch *)sender
{
    self.torusEnabled = sender.on;
}

- (IBAction)switchBloom:(UISwitch *)sender
{
    self.bloomEnabled = sender.on;
}

@end
