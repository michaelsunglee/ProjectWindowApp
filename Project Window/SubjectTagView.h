//
//  SubjectTagView.h
//  Project Window
//
//  Created by Sunny Chan on 9/19/15.
//  Copyright © 2015 Hack The North. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectTagView : UIView

@property (nonatomic, strong) UILabel *tagLabel;

- (instancetype)initWithOrigin:(CGPoint)origin
                     tagString:(NSString *)tagString;

- (void)changeTagString:(NSString *)tagString;

@end
