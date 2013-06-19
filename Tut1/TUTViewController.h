//
//  TUTViewController.h
//  Tut1
//
//  Created by Evgenij on 4/11/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface TUTViewController : GLKViewController
@property (weak, nonatomic) IBOutlet UISwitch *torusSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *bloomSwitch;
@property (weak, nonatomic) IBOutlet UILabel *labelFPS;
@property (weak, nonatomic) IBOutlet UILabel *labelFPS2;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;
- (IBAction)handlePan:(UIPanGestureRecognizer *)sender;
- (IBAction)switchMSAA:(UISwitch *)sender;
- (IBAction)switchTorus:(UISwitch *)sender;
- (IBAction)switchBloom:(UISwitch *)sender;

@end
