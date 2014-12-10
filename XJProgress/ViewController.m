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
    [XJProgress showProgress];
    
    dispatch_main_after(2.0f, ^{
        [XJProgress updateProgress:0.3f
                           animated:YES];
    });
    dispatch_main_after(2.5f, ^{
        [XJProgress updateProgress:0.5f
                           animated:YES];
    });
    dispatch_main_after(2.8f, ^{
        [XJProgress updateProgress:0.6f
                           animated:YES];
    });
    dispatch_main_after(3.7f, ^{
        [XJProgress updateProgress:0.93f
                           animated:YES];
    });
    dispatch_main_after(5.0f, ^{
        [XJProgress updateProgress:1.0f
                           animated:YES];
    });

    
    dispatch_main_after(8.0f, ^{
        [XJProgress dismiss];
    });

}

static void dispatch_main_after(NSTimeInterval delay, void (^block)(void))
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}


@end
