//
//  ViewController.h
//  Project Window
//
//  Created by Sunny Chan on 9/19/15.
//  Copyright © 2015 Hack The North. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <OpenEars/OEFliteController.h>
//#import <Slt/Slt.h>
//#import <Slt8k/Slt8k.h>
#import <SpeechKit/SpeechKit.h>

#import "CameraSessionView.h"

@interface ViewController : UIViewController <CACameraSessionDelegate, SpeechKitDelegate, SKVocalizerDelegate>

@property (nonatomic, strong) CameraSessionView *cameraView;

//@property (strong, nonatomic) OEFliteController *fliteController;
//@property (strong, nonatomic) Slt *slt;
//@property (strong, nonatomic) Slt8k *slt8k;

@end

