//
//  UAImageViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 08/04/2013.
//  Copyright 2013 Nial Giacomelli
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
#import "UAImageViewController.h"

@interface UAImageViewController ()
{
    UIBarButtonItem *cancelBarButtonItem;
    UIView *backgroundView;
    UIView *containerView;
    CGFloat initialZoom;
}
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UAImageScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGRect presentationRect;

- (void)resetImageZoom;
@end

@implementation UAImageViewController
@synthesize image = _image;

#pragma mark - Setup
- (id)initWithImage:(UIImage *)aImage
{
    self = [super init];
    if (self) {
        
        _image = aImage;        
        
        UITapGestureRecognizer *doubleTapGestureRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetImageZoom)];
        doubleTapGestureRecognzier.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTapGestureRecognzier];
        
        UITapGestureRecognizer *tapGestureRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [tapGestureRecognzier requireGestureRecognizerToFail:doubleTapGestureRecognzier];
        [self.view addGestureRecognizer:tapGestureRecognzier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:@"UIDeviceOrientationDidChangeNotification"
                                                   object:nil];
    }
    return self;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor clearColor];
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.0f;
    
    containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    containerView.backgroundColor = [UIColor clearColor];
    containerView.alpha = 0.0f;
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.scrollView = [[UAImageScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.maximumZoomScale = 3.0f;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.zoomScale = 1.0f;
    self.scrollView.decelerationRate = .85f;
    self.scrollView.contentSize = CGSizeZero;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollView.delegate = self;
    self.scrollView.containerView = self.imageView;
    [self.scrollView addSubview:self.imageView];
    
    [view addSubview:backgroundView];
    [containerView addSubview:self.scrollView];
    [view addSubview:containerView];
    self.view = view;
}

#pragma mark - Logic
- (void)presentFromRect:(CGRect)rect
{
    self.view.backgroundColor = [UIColor clearColor];
    self.presentationRect = rect;
    
    containerView.alpha = 0.0f;
    containerView.frame = self.presentationRect;
    self.scrollView.contentSize = self.view.frame.size;
    self.imageView.frame = self.scrollView.frame;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.1 animations:^{
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            backgroundView.alpha = 1.0f;
        }];
    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        containerView.alpha = 1.0f;
        containerView.frame = self.view.frame;
        //self.scrollView.frame = self.view.frame;
    } completion:^(BOOL finished) {

    }];
}
- (void)dismiss
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.1 animations:^{
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            backgroundView.alpha = 0.0f;
        }];
    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        containerView.alpha = 0.0f;
        containerView.frame = self.presentationRect;
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
- (void)resetImageZoom
{
    [self.scrollView setZoomScale:1.0f animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView
{
    return self.imageView;
}

#pragma mark - Autorotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationMaskPortrait);
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)orientationChanged:(NSNotification *)note
{
    UIDeviceOrientation appOrientation = [[UIDevice currentDevice] orientation];

    CGFloat rotation = 0;
    switch (appOrientation)
    {
        case UIInterfaceOrientationPortrait:
            rotation = 0;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotation = 3*M_PI_2;
            break;
        default:
            rotation = 0;
            break;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [UIView animateWithDuration:[application statusBarOrientationAnimationDuration]
                     animations:^(void) {
    
        CGAffineTransform transform = CGAffineTransformIdentity; //self.view.transform;
        transform = CGAffineTransformRotate(transform, rotation);
        containerView.transform = transform;

        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.zoomScale = 1.0f;

        // if is rotated from Portait:
        if(UIInterfaceOrientationIsLandscape(appOrientation))
        {
            [containerView setBounds:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
            [self.scrollView setContentSize:CGSizeMake(containerView.bounds.size.height, containerView.bounds.size.width)];
        }
        else if(UIInterfaceOrientationIsPortrait(appOrientation))
        {
            [containerView setBounds:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [self.scrollView setContentSize:CGSizeMake(containerView.bounds.size.width, containerView.bounds.size.height)];
        }
        //self.scrollView.maximumZoomScale = self.imageView.image.size.width / self.scrollView.frame.size.width;
    }];
}
@end
