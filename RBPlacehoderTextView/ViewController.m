//
//  ViewController.m
//  RBPlacehoderTextView
//
//  Created by Yongchao on 22/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//

#import "ViewController.h"
#import "RBPlacehoderTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    RBPlacehoderTextView *textView = [[RBPlacehoderTextView alloc] initWithFrame:CGRectMake(10.f, 45.f, self.view.frame.size.width - 20.f, 200.f)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.backgroundColor = [UIColor lightTextColor];
    textView.layer.borderColor = [[UIColor colorWithWhite:.8 alpha:1.0] CGColor];
    textView.layer.borderWidth = 0.65f;
    textView.layer.cornerRadius = 6.0f;
    textView.placeHolder = @"PlaceHolder";
    textView.placeHolderTextColor = [UIColor redColor];
    
    [self.view addSubview:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
