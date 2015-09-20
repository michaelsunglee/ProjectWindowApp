//
//  SubjectTagView.m
//  Project Window
//
//  Created by Sunny Chan on 9/19/15.
//  Copyright © 2015 Hack The North. All rights reserved.
//

#import "SubjectTagView.h"

@interface SubjectTagView ()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@end

@implementation SubjectTagView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithOrigin:(CGPoint)origin
                     tagString:(NSString *)tagString
{
    self = [super init];
    if (self) {
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.tagLabel.text = tagString;
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.tagLabel sizeToFit];
        CGRect frameWithMargin = self.tagLabel.frame;
        frameWithMargin.size.width += 35;
        frameWithMargin.size.height += 20;
        self.tagLabel.frame = frameWithMargin;
        
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.blurEffectView.frame = CGRectMake(origin.x,
                                          origin.y,
                                          self.tagLabel.frame.size.width,
                                          self.tagLabel.frame.size.height);
        self.blurEffectView.layer.cornerRadius = 20;
        self.blurEffectView.layer.masksToBounds = YES;
        [self.blurEffectView addSubview:self.tagLabel];
        [self addSubview:self.blurEffectView];

    }
    return self;
}

- (void)changeTagString:(NSString *)tagString
{
    self.tagLabel.text = tagString;
    
    [self.tagLabel sizeToFit];
    CGRect frameWithMargin = self.tagLabel.frame;
    frameWithMargin.size.width += 35;
    frameWithMargin.size.height += 20;
    self.tagLabel.frame = frameWithMargin;
    
    self.blurEffectView.frame = CGRectMake(self.blurEffectView.frame.origin.x,
                                           self.blurEffectView.frame.origin.y,
                                           self.tagLabel.frame.size.width,
                                           self.tagLabel.frame.size.height);
}

@end
