//
//  ViewController.m
//  XJProgress
//
//  Created by jimi on 2014/12/10.
//  Copyright (c) 2014年 XJIMI. All rights reserved.
//

#import "ViewController.h"
#import "XJProgress.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)showProgress
{
    
    [XJProgress showProgressInView:self.view];
    
    dispatch_main_after(0.5f, ^{
        [XJProgress updateProgress:0.5f animated:YES];
    });
     
    dispatch_main_after(1.5f, ^{
        [XJProgress updateProgress:1.0f animated:YES];
    });

    
    dispatch_main_after(2.5f, ^{
        [XJProgress showErrorWithMessage:@"Errorr" inView:self.view];
    });
}

static void dispatch_main_after(NSTimeInterval delay, void (^block)(void))
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}


@end
