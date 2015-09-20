//
//  ViewController.m
//  Project Window
//
//  Created by Sunny Chan on 9/19/15.
//  Copyright © 2015 Hack The North. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "ImgurSession.h"
#import "SubjectTagView.h"
#import "UNIRest.h"

const unsigned char SpeechKitApplicationKey[] =
{
    0xf7, 0xa5, 0x66, 0xc9, 0x15, 0x14, 0x04, 0xd1, 0xb2, 0xb1, 0x04,
    0x9d, 0x86, 0x61, 0xea, 0x7a, 0x16, 0xa2, 0x0f, 0x82, 0x4c, 0x99,
    0xb5, 0x43, 0x54, 0x39, 0xfe, 0x66, 0x36, 0x33, 0xa2, 0x2e, 0xd9,
    0x09, 0xf7, 0xee, 0x1d, 0xfb, 0xbf, 0xcf, 0xad, 0xc3, 0x6c, 0x33,
    0x24, 0x56, 0xae, 0x3a, 0xf8, 0xbd, 0xbc, 0x44, 0x56, 0x72, 0x87,
    0xaa, 0xab, 0x85, 0x10, 0xe1, 0xb9, 0xb2, 0x0f, 0x92
};

@interface ViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UITapGestureRecognizer *tapToCapture;
@property (nonatomic, strong) SKVocalizer *vocalizer;
@property (nonatomic, strong) UIImageView *capturedPhotoView;

@property (nonatomic, strong) NSMutableArray *tagArray;
@property (nonatomic, strong) SubjectTagView *tag0;
@property (nonatomic, strong) SubjectTagView *tag1;
@property (nonatomic, strong) SubjectTagView *tag2;

@property (nonatomic, assign) BOOL tellingResults;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up tap gesture
    self.tapToCapture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(screenTapped:)];
    [self.view addGestureRecognizer:self.tapToCapture];
    
    // Set up camera view
    self.cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    // [self.cameraView hideCameraToogleButton]; // doesn't work, hidden in CameraSessionView.m
    // [self.cameraView hideDismissButton]; // doesn't work, hidden in CameraSessionView.m
    // [self.cameraView hideFlashButton]; // doesn't work, hidden in CameraSessionView.m
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    
    // Set up voice guide
//    self.fliteController = [[OEFliteController alloc] init];
//    self.slt = [[Slt alloc] init];
//    self.slt8k = [[Slt8k alloc] init];
//    
    // Set up SpeechKit
    [SpeechKit setupWithID:@"NMDPTRIAL_sunnychan626_me_com20150919143119"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:self];
    self.vocalizer = [[SKVocalizer alloc] initWithLanguage:@"en_US"
                                                  delegate:self];
    
    // Set up capturedPhotoView
    self.capturedPhotoView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.capturedPhotoView];
    
    // Set up loading indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    
    // Set up Subject Tag Views
    self.tag0 = [[SubjectTagView alloc] initWithOrigin:CGPointMake(40, self.view.frame.size.height - 200)
                                                       tagString:@"something"];
    self.tag0.alpha = 0;
    [self.view addSubview:self.tag0];
    self.tag1 = [[SubjectTagView alloc] initWithOrigin:CGPointMake(40, self.view.frame.size.height - 150)
                                                       tagString:@"another thing"];
    self.tag1.alpha = 0;
    [self.view addSubview:self.tag1];
    self.tag2 = [[SubjectTagView alloc] initWithOrigin:CGPointMake(40, self.view.frame.size.height - 100)
                                                        tagString:@"some other thing"];
    self.tag2.alpha = 0;
    [self.view addSubview:self.tag2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Capture

- (void)screenTapped:(UITapGestureRecognizer *)tapGesture
{
    NSLog(@"screen tapped");
    [self.cameraView onTapShutterButton];
}

- (void)enableShutter:(BOOL)enabled
{
    [self.cameraView enableShutterButton:enabled];
    [self.tapToCapture setEnabled:enabled];
}

#pragma mark - CACameraSessionDelegate

- (void)didTapShutter
{
    [self enableShutter:NO];
}

- (void)didCaptureImage:(UIImage *)image
{
    self.capturedPhotoView.image = image;
    self.capturedPhotoView.alpha = 1.0;
}

- (void)didCaptureImageWithData:(NSData *)imageData
{
    NSLog(@"image captured");
    [self.vocalizer speakString:@"photo captured, uploading to mainframe"];
    //    [self.fliteController say:@"image captured, analyzing"
    //                    withVoice:self.slt8k];
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); // vibrate
    [self displayLoadingIndicator:YES];
    [self uploadImageToImgurWithImageData:imageData];
}

#pragma mark - SKVocalizer Delegate 
- (void)vocalizer:(SKVocalizer *)vocalizer
willBeginSpeakingString:(NSString *)text {
    // Update UI to indicate that text is being spoken
    NSLog(@"%@", text);
    if ([text containsString:@"think"]) {
        self.tellingResults = YES;
        [self displayLoadingIndicator:NO];
        [self fadeSubjectTagViews:YES];
    }
}

- (void)vocalizer:(SKVocalizer *)vocalizer
didFinishSpeakingString:(NSString *)text
        withError:(NSError *)error {
    
    if (error) {
        // Present error dialog to user
    } else {
        // Update UI to indicate speech is complete
        if (self.tellingResults) {
            self.tellingResults = NO;
            [self fadeSubjectTagViews:NO];
            self.capturedPhotoView.alpha = 0.0;
            [self enableShutter:YES];
        }  
    }
}

#pragma mark - Loading Indicator
- (void)displayLoadingIndicator:(BOOL)display
{
    if (display) {
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimating];
    } else {
        [self.loadingIndicator stopAnimating];
    }
}

#pragma mark - imgur uploader
- (void)uploadImageToImgurWithImageData:(NSData *)imageData
{
    if (!imageData) {
        return;
    }
    
    [IMGImageRequest uploadImageWithData:imageData
                                   title:@"Untitled"
                                 success:^(IMGImage *image) {
                                     NSLog(@"image url: %@", image.url);
                                     [self.vocalizer speakString:@"i've got the photo, let me see..."];
                                     [self sendRequestToClarifaiWithImageURL:image.url];
                                 }
                                progress:nil
                                 failure:^(NSError *error) {
                                     [self.vocalizer speakString:@"please try again. my bad."];
                                 }
     ];
}

#pragma mark - Connect to Clarifai
- (void)sendRequestToClarifaiWithImageURL:(NSURL *)url
{
    NSDictionary *headers = @{ @"Authorization": @"Bearer HPbPTvr82n4Cus4OcG4MsIMktcud6t" };
    NSDictionary *parameters = @{ @"url" : url.absoluteString };
    
    UNIHTTPJsonResponse *response = [[UNIRest post:^(UNISimpleRequest *request) {
        [request setUrl:@"https://api.clarifai.com/v1/tag/"];
        [request setHeaders:headers];
        [request setParameters:parameters];
    }] asJson];

    NSArray *thingsRecognized = [[[[[response.body.object objectForKey:@"results"] objectAtIndex:0] objectForKey:@"result"] objectForKey:@"tag"] objectForKey:@"classes"];

    NSLog(@"%@", [thingsRecognized description]);
    
    [self.tag0 changeTagString:[thingsRecognized objectAtIndex:0]];
    [self.tag1 changeTagString:[thingsRecognized objectAtIndex:1]];
    [self.tag2 changeTagString:[thingsRecognized objectAtIndex:2]];
    
    [self.vocalizer speakString:[NSString stringWithFormat:@"i think i see, %@, %@, and %@", self.tag0.tagLabel.text, self.tag1.tagLabel.text, self.tag2.tagLabel.text]];
}

#pragma mark - Subject Tag Views
- (void)fadeSubjectTagViews:(BOOL)show
{
    CGFloat alpha = 0;
    if (show) {
        alpha = 1;
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.tag0.alpha = alpha;
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.5
                          delay:(show ? 0.2 : 0.0)
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.tag1.alpha = alpha;
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.5
                          delay:(show ? 0.4 : 0.0)
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.tag2.alpha = alpha;
                     }
                     completion:nil];
}

@end
