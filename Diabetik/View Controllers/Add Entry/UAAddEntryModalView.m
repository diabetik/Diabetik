//
//  UAAddEntryModalView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 02/04/2013.
//  Copyright (c) 2013-2014 Nial Giacomelli
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <QuartzCore/QuartzCore.h>
#import "UAAddEntryModalView.h"
#import "UAAddEntryModalButton.h"

@interface UAAddEntryModalView ()
{
    NSMutableArray *buttons;
    UIView *container;
    UIView *backgroundView;
}
@end

@implementation UAAddEntryModalView

#pragma mark - Setup
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect containerFrame = frame;// CGRectInset(frame, 15.0f, 25.0f);
        
        backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        backgroundView.alpha = 0.0f;
        [self addSubview:backgroundView];
        
        container = [[UIView alloc] initWithFrame:containerFrame];
        container.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:236.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
        container.alpha = 0.0f;
        [self addSubview:container];
        
        CGFloat width = floorf((container.frame.size.width-3.0f)/2.0f);
        CGFloat height = floorf((container.frame.size.height-3.0f)/3.0f);
        
        buttons = [[NSMutableArray alloc] init];
        UAAddEntryModalButton *medicineButton = [[UAAddEntryModalButton alloc] initWithFrame:CGRectMake(1.0f, 0.0f, width, height)];
        [medicineButton setTag:0];
        [medicineButton setImage:[UIImage imageNamed:@"AddEntryModalMedicineIcon.png"] forState:UIControlStateNormal];
        [medicineButton setTitle:NSLocalizedString(@"Medication", nil) forState:UIControlStateNormal];
        [medicineButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:medicineButton];
        
        UAAddEntryModalButton *readingButton = [[UAAddEntryModalButton alloc] initWithFrame:CGRectMake(2.0f + width, 0.0f, width, height)];
        [readingButton setTag:1];
        [readingButton setImage:[UIImage imageNamed:@"AddEntryModalBloodIcon.png"] forState:UIControlStateNormal];
        [readingButton setTitle:NSLocalizedString(@"Reading", @"Blood glucose reading entry type") forState:UIControlStateNormal];
        [readingButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:readingButton];
        
        UAAddEntryModalButton *mealButton = [[UAAddEntryModalButton alloc] initWithFrame:CGRectMake(1.0f, 1.0f + height, width, height)];
        [mealButton setTag:2];
        [mealButton setImage:[UIImage imageNamed:@"AddEntryModalMealIcon.png"] forState:UIControlStateNormal];
        [mealButton setTitle:NSLocalizedString(@"Food", @"Food entry type") forState:UIControlStateNormal];
        [mealButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:mealButton];
        
        UAAddEntryModalButton *activityButton = [[UAAddEntryModalButton alloc] initWithFrame:CGRectMake(2.0f + width, 1.0f + height, width, height)];
        [activityButton setTag:3];
        [activityButton setImage:[UIImage imageNamed:@"AddEntryModalActivityIcon.png"] forState:UIControlStateNormal];
        [activityButton setTitle:NSLocalizedString(@"Activity", @"Activity (physical exercise)") forState:UIControlStateNormal];
        [activityButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:activityButton];
        
        UAAddEntryModalButton *noteButton = [[UAAddEntryModalButton alloc] initWithFrame:CGRectMake(1.0f, 2.0f + height*2, width, height)];
        [noteButton setTag:4];
        [noteButton setImage:[UIImage imageNamed:@"AddEntryModalNoteIcon.png"] forState:UIControlStateNormal];
        [noteButton setTitle:NSLocalizedString(@"Note", @"Note entry type") forState:UIControlStateNormal];
        [noteButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:noteButton];
        
        UAAddEntryModalButton *cancelButton = [[UAAddEntryModalButton alloc] initWithFrame:CGRectMake(2.0f + width, 2.0f + height*2, width, height)];
        [cancelButton setTag:5];
        [cancelButton setImage:[UIImage imageNamed:@"AddEntryModalCancelIcon.png"] forState:UIControlStateNormal];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(selectedOption:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:cancelButton];
        
        [buttons addObject:medicineButton];
        [buttons addObject:readingButton];
        [buttons addObject:mealButton];
        [buttons addObject:activityButton];
        [buttons addObject:noteButton];
        [buttons addObject:cancelButton];
    }
    return self;
}

#pragma mark - Logic
- (void)present
{
    [UIView animateWithDuration:0.05f animations:^{
        backgroundView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
    
    container.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{container.alpha = 1.0;}];
    container.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.2;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.fillMode = kCAFillModeForwards;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [container.layer addAnimation:bounceAnimation forKey:@"bounce"];
    container.layer.transform = CATransform3DIdentity;
}
- (void)dismiss
{
    container.alpha = 1;
    [UIView animateWithDuration:0.15 animations:^{container.alpha = 0.0;}];
    
    container.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:0.0], nil];
    bounceAnimation.duration = 0.3;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.fillMode = kCAFillModeForwards;
    bounceAnimation.delegate = self;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [container.layer addAnimation:bounceAnimation forKey:@"bounce"];
    container.layer.transform = CATransform3DIdentity;
    
    
    [UIView animateWithDuration:0.6f animations:^{
        backgroundView.alpha = 0.0f;
        container.alpha = 0.0f;
    } completion:^(BOOL finished) {
    }];
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self removeFromSuperview];
}

#pragma mark - UI
- (void)selectedOption:(UIButton *)sender
{
    [[VKRSAppSoundPlayer sharedInstance] playSound:(sender.tag == 5 ? @"pop-view" : @"tap-significant")];
    
    [self.delegate addEntryModal:self didSelectEntryOption:sender.tag];
}

@end
