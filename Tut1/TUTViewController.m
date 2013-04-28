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
#import "Camera.h"
#import "Light.h"
#import "FBOShadow.h"
#import "SceneEffect.h"
#import "GLSLProgram.h"

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
@property (strong, nonatomic) Camera *camera;
@property (strong, nonatomic) Light *light;
@property (strong, nonatomic) SceneEffect *sceneEffect;

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
    for (NSString *oneExtension in extensions)
        NSLog(@"%@", oneExtension);
#endif

    self.sceneEffect = [SceneEffect new];
    self.light = [[Light alloc] initWithPosition:GLKVector4Make(-4.0f, 7.0f, 4.0f, 1.0f)
                                          center:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                              up:GLKVector3Make(0.0f, 1.0f, 0.0f)
                                            fovy:GLKMathDegreesToRadians(65.0f)
                                          aspect:1.0f nearZ:1.0f farZ:20.0f
                                       intensity:GLKVector3Make(1.0f, 1.0f, 1.0f)];

    MaterialInfo material = {
        .Ke=GLKVector3Make(0.0f, 0.0f, 0.0f),
        .Ka=GLKVector3Make(0.035f, 0.025f, 0.015f),
        .Kd=GLKVector3Make(0.9f, 0.7f, 0.5f),
        .Ks=GLKVector3Make(1.5f, 1.5f, 1.5f),
        .shininess=150.0f
    };
    self.teapot = [[VBOTeapot alloc] initWithGrid:14 andLidTransfrom:GLKMatrix4Identity];
    self.teapot.material = material;
    self.teapot.constantColor = GLKVector3Make(0.7f, 0.8f, 0.2f);
    self.floor = [VBOFloor new];
    material.Ks = GLKVector3Make(0.2f, 0.2f, 0.2f);
    material.shininess = 10.0f;
    self.floor.material = material;
    self.floor.constantColor = GLKVector3Make(0.8f, 0.8f, 0.8f);
    self.torus = [VBOTorus new];
    material.Ks = GLKVector3Make(5.5f, 7.5f, 9.5f);
    material.Ke = GLKVector3Make(0.1f, 0.1f, 0.3f);
    material.shininess = 100.0f;
    self.torus.material = material;

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    self.camera = [[Camera alloc] initWithEye:GLKVector3Make(-1.0f, 7.0f, 5.0f)
                                       center:GLKVector3Make(0.0f, 0.0f, 0.0f)
                                           up:GLKVector3Make(0.0f, 1.0f, 0.0f)
                                         fovy:GLKMathDegreesToRadians(65.0f) aspect:aspect
                                        nearZ:0.1f farZ:50.0f];

    glClearColor(0.35f, 0.65f, 0.95f, 1.0f);
    glPolygonOffset(1.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);

    ((GLKView *)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
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
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    self.camera.aspect = aspect;

    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    self.floor.modelMatrix = modelMatrix;

    modelMatrix = GLKMatrix4MakeTranslation(-2.0f, 4.0f, 2.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    self.torus.modelMatrix = modelMatrix;

    // Compute the model view matrix for the object rendered with ES2
    modelMatrix = GLKMatrix4MakeTranslation(2.0f, 0.0f, -2.0f);
    modelMatrix = GLKMatrix4RotateY(modelMatrix, _rotation);
    modelMatrix = GLKMatrix4RotateX(modelMatrix, GLKMathDegreesToRadians(-90.0f));
    self.teapot.modelMatrix = modelMatrix;

    _rotation += self.timeSinceLastUpdate * 0.5f;

    [self.torus updateWithTime:_rotation * 10];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    CFTimeInterval previousTimestamp = CFAbsoluteTimeGetCurrent();

    // Pass 1 (shadow map generation)
    self.light.shadow.enabled = YES;
    [self renderWith:self.light.shadow];
    self.light.shadow.enabled = NO;
    [(GLKView *)self.view bindDrawable];

    // Pass 2 (render)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glCullFace(GL_BACK);
    self.sceneEffect.light = self.light;
    self.sceneEffect.camera = self.camera;
    [self.sceneEffect prepareToDraw];
    [self renderWith:self.sceneEffect];

//    glUseProgram(0);

    CFTimeInterval frameDuration = CFAbsoluteTimeGetCurrent() - previousTimestamp;
    if (self.framesDisplayed % 20 == 0) {
        self.labelFPS.text = [NSString stringWithFormat:@"%f", 1 / frameDuration];
    }
    self.labelFPS2.text = [NSString stringWithFormat:@"%d", self.framesPerSecond];
}

- (void)renderWith:(id<Effect>)effect
{
    // TODO: Sort objects in Z-order
    [effect prepareToDraw:self.teapot];
    [self.teapot render];
    [effect prepareToDraw:self.torus];
    [self.torus render];
    [effect prepareToDraw:self.floor];
    [self.floor render];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    self.paused = !self.paused;
}

@end
