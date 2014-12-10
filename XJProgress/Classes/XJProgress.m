//
//  XJProgress.m
//  XJProgress
//
//  Created by jimi on 2014/12/10.
//  Copyright (c) 2014年 XJIMI. All rights reserved.
//

#import "XJProgress.h"
#import "UIImage+ImageEffects.h"

@interface XJProgress ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIView *circleProgressView;
@property (nonatomic, strong) CAShapeLayer *circleProgressLineLayer;
@property (nonatomic, strong) CAShapeLayer *circleBackgroundLineLayer;


@end

@implementation XJProgress


+ (XJProgress *)sharedObject
{
    static XJProgress *sharedView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[XJProgress alloc] init];
        
        sharedView.backgroundView = [[UIImageView alloc] init];
        sharedView.circleProgressView = [[UIView alloc] init];
        
        [sharedView addSubview:sharedView.backgroundView];
        [sharedView addSubview:sharedView.circleProgressView];
    });
    return sharedView;
}

+ (void)showProgress
{
    [[self sharedObject] showProgress];
}

+ (void)dismiss
{
    [[self sharedObject] dismiss];
}

- (void)dismiss
{
    [UIView animateKeyframesWithDuration:.3 delay:0 options:0 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showProgress
{
    [self addToWindow];
    self.backgroundView.frame = self.frame;
    self.backgroundView.image = [self blurredScreenShot];
    [self addProgressCircle];
    
    
    [UIView animateKeyframesWithDuration:.3 delay:0 options:0 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addProgressCircle
{
    CGFloat circlePorgressViewSize = self.frame.size.width * .3;
    CGFloat circleProgressViewCenter = (self.frame.size.width - circlePorgressViewSize) * .5;
    self.circleProgressView.frame = CGRectMake(circleProgressViewCenter, circleProgressViewCenter, circlePorgressViewSize, circlePorgressViewSize);
    self.circleProgressView.backgroundColor = [UIColor purpleColor];
    
    CGFloat radius = (self.circleProgressView.bounds.size.width * .5);
    CGPoint center = CGPointMake(radius, radius);
    CGFloat lineWith = 2.0f;

    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:radius - 1 - lineWith
                                                          startAngle:-M_PI_2
                                                            endAngle:-M_PI_2 + 2  * M_PI
                                                           clockwise:YES];

    self.circleProgressLineLayer = [CAShapeLayer layer];
    self.circleProgressLineLayer.path = circlePath.CGPath;
    //self.circleProgressLineLayer.strokeColor = self.circleStrokeForegroundColor.CGColor;
    self.circleProgressLineLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:.8].CGColor;
    self.circleProgressLineLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleProgressLineLayer.lineWidth = lineWith;
    
    self.circleBackgroundLineLayer = [CAShapeLayer layer];
    self.circleBackgroundLineLayer.path = circlePath.CGPath;
    //self.circleBackgroundLineLayer.strokeColor = self.circleStrokeBackgroundColor.CGColor;
    self.circleBackgroundLineLayer.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
    self.circleBackgroundLineLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleBackgroundLineLayer.lineWidth = lineWith;
    
    [self.circleProgressView.layer addSublayer:self.circleBackgroundLineLayer];
    [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
    
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleProgressView.layer removeAllAnimations];
    
    [self updateProgress:self.progress animated:NO];
}

+ (void)updateProgress:(CGFloat)progress animated:(BOOL)animated
{
    [[self sharedObject] updateProgress:progress animated:animated];
}

- (void)updateProgress:(CGFloat)progress animated:(BOOL)animated
{
    /*
    if (self.style != KVNProgressStyleProgress) {
        return;
    }*/
    
   
    // Boundry correctness
    progress = MIN(progress, 1.0f);
    progress = MAX(progress, 0.0f);
    
    
    if (animated) {
        CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        
        progressAnimation.duration = 0.3f;
        progressAnimation.removedOnCompletion = NO;
        progressAnimation.fillMode = kCAFillModeBoth;
        progressAnimation.fromValue = @(self.progress);
        progressAnimation.toValue = @(progress);
        progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [self.circleProgressLineLayer addAnimation:progressAnimation forKey:@"strokeEnd"];
    } else {
        self.circleProgressLineLayer.strokeEnd = progress;
    }
    
    self.progress = progress;
}


- (void)addToWindow
{
    UIWindow *currentWindow = nil;
    
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            currentWindow = window;
            break;
        }
    }
    
    if (self.superview != currentWindow) {
        [self addToView:currentWindow];
    }
}

- (void)addToView:(UIView *)superview
{
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    [superview addSubview:self];
    [superview bringSubviewToFront:self];
    self.frame = superview.frame;
    self.alpha = 0.0f;
}

- (UIImage *)blurredScreenShot
{
    return [self blurredScreenShotWithRect:[UIApplication sharedApplication].keyWindow.frame];
}

- (UIImage *)blurredScreenShotWithRect:(CGRect)rect
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [keyWindow drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    UIImage *blurredScreenShot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [blurredScreenShot applyBlurWithRadius:30.0f
                                        tintColor:[[UIColor darkGrayColor] colorWithAlphaComponent:.5]
                            saturationDeltaFactor:1.0f
                                        maskImage:nil];
}



@end
