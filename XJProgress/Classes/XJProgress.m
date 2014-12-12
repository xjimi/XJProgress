//
//  XJProgress.m
//  XJProgress
//
//  Created by jimi on 2014/12/10.
//  Copyright (c) 2014年 XJIMI. All rights reserved.
//

#import "XJProgress.h"
#import "UIImage+ImageEffects.h"

typedef NS_ENUM(NSUInteger, XJProgressType) {
    XJProgressTypeProgress,
    XJProgressTypeSuccess,
    XJProgressTypeError
};

@interface XJProgress ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIView *circleProgressView;
@property (nonatomic, strong) CAShapeLayer *circleProgressLineLayer;
@property (nonatomic, strong) CAShapeLayer *circleBackgroundLineLayer;
@property (nonatomic, strong) CAShapeLayer *checkmarkLayer;
@property (nonatomic, strong) CAShapeLayer *errorLayer;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) CGFloat progressLineWidth;
@property (nonatomic, assign) XJProgressType progressType;

@end

@implementation XJProgress


+ (XJProgress *)sharedObject
{
    static XJProgress *sharedView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[XJProgress alloc] init];
        
        sharedView.backgroundView = [[UIImageView alloc] init];
        sharedView.container = [[UIView alloc] init];
        sharedView.circleProgressView = [[UIView alloc] init];
        sharedView.messageLabel = [[UILabel alloc] init];
        sharedView.messageLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
        sharedView.messageLabel.textColor = [UIColor whiteColor];
        sharedView.messageLabel.textAlignment = NSTextAlignmentCenter;
        sharedView.progressLineWidth = 1.0f;
        
        [sharedView addSubview:sharedView.backgroundView];
        [sharedView addSubview:sharedView.container];
        [sharedView.container addSubview:sharedView.circleProgressView];
        [sharedView.container addSubview:sharedView.messageLabel];
    });
    return sharedView;
}

+ (void)showProgress
{
    [[self sharedObject] showProgress];
}

+ (void)updateProgress:(CGFloat)progress animated:(BOOL)animated
{
    [[self sharedObject] updateProgress:progress animated:animated];
}

+ (void)showSuccess
{
    [[self sharedObject] showSuccess];
}

+ (void)showError
{
    [[self sharedObject] showError];
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
    [self showWithProgressType:XJProgressTypeProgress];
}

- (void)showSuccess
{
    [self showWithProgressType:XJProgressTypeSuccess];
}

- (void)showError
{
    [self showWithProgressType:XJProgressTypeError];
}

- (void)showWithProgressType:(XJProgressType)progressType
{
    self.progressType = progressType;
    if (!self.superview)
    {
        [self addToWindow];
        [self addBackground];
        [UIView animateWithDuration:.3 delay:0 options:0 animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    }
    
    switch (self.progressType)
    {
        case XJProgressTypeProgress:
            [self refreshViewFrame];
            [self addProgressView];
            break;
        case XJProgressTypeSuccess:
            [self addSuccessView];
            break;
        case XJProgressTypeError:
            [self addErrorView];
            break;
    }
}

- (void)removeAllSubLayersOfLayer:(CALayer *)layer
{
    for (CALayer *subLayer in [layer.sublayers copy]) {
        [subLayer removeFromSuperlayer];
    }
}


- (void)addBackground
{
    self.backgroundView.frame = self.frame;
    self.backgroundView.image = [self blurredScreenShot];
}

- (UIBezierPath *)circleProgressBezierPath
{
    CGFloat radius = (self.circleProgressView.frame.size.width * .5);
    CGPoint center = CGPointMake(radius, radius);
    CGFloat lineWith = 1.0f;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:radius - 1 - lineWith
                                                          startAngle:-M_PI_2
                                                            endAngle:-M_PI_2 + 2  * M_PI
                                                           clockwise:YES];
    return circlePath;
}

- (void)addCircleProgressLineWithLineColor:(UIColor *)lineColor
{
    if (![self.circleProgressView.layer.sublayers containsObject:self.circleProgressLineLayer])
    {
        UIBezierPath *circlePath = [self circleProgressBezierPath];
        self.circleProgressLineLayer = [CAShapeLayer layer];
        self.circleProgressLineLayer.path = circlePath.CGPath;
        self.circleProgressLineLayer.strokeColor = lineColor.CGColor;
        self.circleProgressLineLayer.fillColor = [UIColor clearColor].CGColor;
        self.circleProgressLineLayer.lineWidth = self.progressLineWidth;
        [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
        [self.circleProgressLineLayer removeAllAnimations];
        [self.circleProgressView.layer removeAllAnimations];
    }
}

- (void)addSuccessView
{
    [self addCircleProgressLineWithLineColor:[[UIColor whiteColor] colorWithAlphaComponent:.8]];
    
    CGRect rect = self.circleProgressView.frame;
    CGFloat radius = roundf(rect.size.width/4);
    UIBezierPath *tickPath = [UIBezierPath bezierPath];
    CGFloat tickWidth = roundf(radius/3);
    CGFloat lineWidth = 1;
    [tickPath moveToPoint:CGPointMake(0, 0)];                                               // A
    [tickPath addLineToPoint:CGPointMake(0, tickWidth * 2)];                                // B
    [tickPath addLineToPoint:CGPointMake(tickWidth * 3.5, tickWidth * 2)];                  // C
    [tickPath addLineToPoint:CGPointMake(tickWidth * 3.5, (tickWidth * 2) - lineWidth)];    // D
    [tickPath addLineToPoint:CGPointMake(lineWidth, (tickWidth * 2) - lineWidth)];          // E
    [tickPath addLineToPoint:CGPointMake(lineWidth, 0)];                                    // F
    [tickPath applyTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    [tickPath applyTransform:CGAffineTransformMakeTranslation(radius*.4, radius)];

    CGFloat xOffset = rect.size.width/2 - radius;
    CGFloat yOffset = rect.size.height/2 - radius;
    [tickPath applyTransform:CGAffineTransformMakeTranslation(xOffset, yOffset)];
    
    self.checkmarkLayer = [CAShapeLayer layer];
    self.checkmarkLayer.path = tickPath.CGPath;
    self.checkmarkLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0].CGColor;
    self.checkmarkLayer.lineWidth = self.progressLineWidth;

    [self.circleProgressView.layer addSublayer:self.checkmarkLayer];
    [self.checkmarkLayer removeAllAnimations];
    
    [self animateFullCircleWithColor:[[UIColor whiteColor] colorWithAlphaComponent:1]];

    
    //改POP
    CABasicAnimation *checkmarkAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    checkmarkAnimation.duration = .3;
    checkmarkAnimation.removedOnCompletion = NO;
    checkmarkAnimation.fillMode = kCAFillModeBoth;
    checkmarkAnimation.toValue = (id)[[UIColor whiteColor] colorWithAlphaComponent:1].CGColor;
    [self.checkmarkLayer addAnimation:checkmarkAnimation forKey:@"fillColor"];
    
    CGRect containerFrame = self.container.frame;
    containerFrame.origin.y = self.frame.size.height * .2;
    
    self.messageLabel.alpha = 0.0f;
    self.messageLabel.text = @"Success";
    CGRect messageLabelFrame = self.messageLabel.frame;
    messageLabelFrame.origin.y = CGRectGetMaxY(self.circleProgressView.frame) - 10.0f;
    self.messageLabel.frame = messageLabelFrame;
    messageLabelFrame.origin.y = CGRectGetMaxY(self.circleProgressView.frame);

    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:5 options:0 animations:^{

        self.messageLabel.alpha = 1.0f;
        self.messageLabel.frame = messageLabelFrame;

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.8 delay:.5 usingSpringWithDamping:1.0 initialSpringVelocity:5 options:0 animations:^{
        
            self.container.frame = containerFrame;
            
        } completion:^(BOOL finished) {
            
        }];

    }];
    
}

- (void)addErrorView
{
    [self addCircleProgressLineWithLineColor:[[UIColor whiteColor] colorWithAlphaComponent:.8]];

    CGRect rect = self.circleProgressView.frame;
    CGFloat radius = roundf(rect.size.width/3);
    UIBezierPath *tickPath = [UIBezierPath bezierPath];
    CGFloat tickWidth = roundf(radius/2);

    [tickPath moveToPoint:CGPointMake(0, tickWidth)];
    [tickPath addLineToPoint:CGPointMake(radius, tickWidth)];
    [tickPath moveToPoint:CGPointMake(tickWidth, 0)];
    [tickPath addLineToPoint:CGPointMake(tickWidth, radius)];
    [tickPath applyTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    [tickPath applyTransform:CGAffineTransformMakeTranslation(radius*.3, radius)];
    
    CGFloat xOffset = rect.size.width/2 - radius;
    CGFloat yOffset = rect.size.height/2 - radius;
    [tickPath applyTransform:CGAffineTransformMakeTranslation(xOffset, yOffset)];

    
    self.errorLayer = [CAShapeLayer layer];
    self.errorLayer.path = tickPath.CGPath;
    self.errorLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0].CGColor;
    self.errorLayer.lineWidth = 1;
    
    [self.circleProgressView.layer addSublayer:self.errorLayer];
    [self.errorLayer removeAllAnimations];
    
    [self animateFullCircleWithColor:[[UIColor whiteColor] colorWithAlphaComponent:1]];
    
    
    //改POP
    CABasicAnimation *errorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    errorAnimation.duration = .6;
    errorAnimation.removedOnCompletion = NO;
    errorAnimation.fillMode = kCAFillModeBoth;
    errorAnimation.toValue = (id)[[UIColor whiteColor] colorWithAlphaComponent:1].CGColor;
    [self.errorLayer addAnimation:errorAnimation forKey:@"strokeColor"];
}

- (void)animateFullCircleWithColor:(UIColor *)color
{
    CABasicAnimation *circleAnimation;
    if (self.superview)
    {
        circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        circleAnimation.duration = .6;
        circleAnimation.toValue = (id)color.CGColor;
        circleAnimation.fillMode = kCAFillModeBoth;
        circleAnimation.removedOnCompletion = NO;
    }
    else
    {
        circleAnimation = [CABasicAnimation animationWithKeyPath:@"alpha"];
        circleAnimation.duration = .6;
        circleAnimation.fromValue = @(0);
        circleAnimation.toValue = @(1);
        circleAnimation.fillMode = kCAFillModeBoth;
        circleAnimation.removedOnCompletion = NO;
    }
    
    [self.circleProgressLineLayer addAnimation:circleAnimation
                                        forKey:@"appearance"];
}


- (void)addProgressView
{
    [self removeCircleProgress];
    
    UIBezierPath *circlePath = [self circleProgressBezierPath];
    
    self.circleProgressLineLayer = [CAShapeLayer layer];
    self.circleProgressLineLayer.path = circlePath.CGPath;
    //self.circleProgressLineLayer.strokeColor = self.circleStrokeForegroundColor.CGColor;
    self.circleProgressLineLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleProgressLineLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleProgressLineLayer.lineWidth = self.progressLineWidth;
    
    self.circleBackgroundLineLayer = [CAShapeLayer layer];
    self.circleBackgroundLineLayer.path = circlePath.CGPath;
    //self.circleBackgroundLineLayer.strokeColor = self.circleStrokeBackgroundColor.CGColor;
    self.circleBackgroundLineLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:.3].CGColor;
    self.circleBackgroundLineLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleBackgroundLineLayer.lineWidth = self.progressLineWidth;
    
    [self.circleProgressView.layer addSublayer:self.circleBackgroundLineLayer];
    [self.circleProgressView.layer addSublayer:self.circleProgressLineLayer];
    
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleProgressView.layer removeAllAnimations];
    
    [self updateProgress:self.progress animated:NO];
}

- (void)removeCircleProgress
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.circleProgressView.layer removeAllAnimations];
    [self.circleProgressLineLayer removeAllAnimations];
    [self.circleBackgroundLineLayer removeAllAnimations];
    
    self.circleProgressLineLayer.strokeEnd = 0.0f;
    self.circleBackgroundLineLayer.strokeEnd = 0.0f;
    
    if (self.circleProgressLineLayer.superlayer) {
        [self.circleProgressLineLayer removeFromSuperlayer];
    }
    if (self.circleBackgroundLineLayer.superlayer) {
        [self.circleBackgroundLineLayer removeFromSuperlayer];
    }
    
    self.circleProgressLineLayer = nil;
    self.circleBackgroundLineLayer = nil;
    
    [CATransaction commit];
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

- (void)refreshViewFrame
{
    CGFloat vw = self.frame.size.width;
    CGFloat vh = self.frame.size.height;
    
    CGFloat circlePorgressViewSize = roundf(vw*.25);
    CGFloat messageLabelHeight = 30.0f;
    
    CGFloat containerp = 20.0f;
    CGFloat containerw = vw - containerp * 2;
    CGFloat containerh = circlePorgressViewSize + messageLabelHeight;
    CGFloat containerPosY = (vh - containerh) * .5;
    self.container.frame = CGRectMake(containerp, containerPosY, containerw, containerh);
    
    CGFloat circleProgressViewPosX = (containerw - circlePorgressViewSize) * .5;
    self.circleProgressView.frame = CGRectMake(circleProgressViewPosX, 0, circlePorgressViewSize, circlePorgressViewSize);
    
    CGFloat messageLabelPosY = CGRectGetMaxY(self.circleProgressView.frame);
    CGFloat messageLabelWidth = containerw;
    self.messageLabel.frame = CGRectMake(0, messageLabelPosY, messageLabelWidth, messageLabelHeight);
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
    
    self.alpha = 0.0f;
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
