//
//  XJProgress.h
//  XJProgress
//
//  Created by jimi on 2014/12/10.
//  Copyright (c) 2014年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJProgress : UIView

@property (nonatomic, strong) UIColor *blurBackgroundTintColor;

+ (void)showProgress;

+ (void)updateProgress:(CGFloat)progress animated:(BOOL)animated;

+ (void)dismiss;

@end
