//
//  HNRefreshHelper.m
//  testPopup
//
//  Created by Long Nguyen on 4/26/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "LoadingHelper.h"

#define sizeActivityIndicator               40.0f

@implementation LoadingHelper


+ (LoadingHelper *)shared {
    static LoadingHelper *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[LoadingHelper alloc] init];
    });
    
    return _shared;
}

- (void)loadingWithView:(UIView*)view{
    if (viewContainer == nil){
        [view addSubview:[self createLoadingZap:view]];
        viewContainer.alpha = 1;
    }
}


- (void)loading{
    if (viewContainer == nil){
        [APPSHARE.window addSubview:[self createLoadingZap:APPSHARE.window]];
        [UIView animateWithDuration:0.2 animations:^{
            viewContainer.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}
- (void)removeLoading{
    [UIView animateWithDuration:0.2 animations:^{
        viewContainer.alpha = 0;
    } completion:^(BOOL finished) {
        [viewContainer removeFromSuperview];
        viewContainer = nil;
        viewBg = nil;
        imvLoading = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    }];
}

- (UIView*)createLoadingZap:(UIView*)view{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    viewContainer = [[UIView alloc]initWithFrame:view.frame];
    viewContainer.alpha = 0;
    viewContainer.backgroundColor = [UIColor clearColor];
    
    viewBg = [[UIView alloc]initWithFrame:view.frame];
    viewBg.alpha = 0.6;
    viewBg.backgroundColor = [UIColor blackColor];
    [viewContainer addSubview:viewBg];
    
    UIImageView *imvZap = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imvZap setImage:[UIImage imageNamed:@"zap_loading_z"]];
    imvZap.center = viewContainer.center;
    
    [viewContainer addSubview:imvZap];
    
    imvLoading = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imvLoading setImage:[UIImage imageNamed:@"zap_loading"]];
    imvLoading.center = viewContainer.center;
    
    [viewContainer addSubview:imvLoading];
    [self runSpinAnimationOnView:imvLoading duration:0.3 rotations:M_PI_2 repeat:100000];
    
    [view addSubview:viewContainer];
    
    return viewContainer;
}
- (void)resumeAnimation{
    if (imvLoading!=nil && viewContainer!=nil){
        [self runSpinAnimationOnView:imvLoading duration:0.3 rotations:M_PI_2 repeat:100000];
    }
}

- (void) runSpinAnimationOnView:(UIImageView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: rotations * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
@end
