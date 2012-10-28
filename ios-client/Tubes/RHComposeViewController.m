//
//  RHComposeViewController.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHComposeViewController.h"

@interface RHComposeViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation RHComposeViewController

- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Compose";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send:)];
    
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"subtle_surface.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *innerView = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, 20, 20)];
    innerView.backgroundColor = [UIColor whiteColor];
    innerView.layer.cornerRadius = 8.0f;
    innerView.layer.masksToBounds = YES;
    innerView.tag = 400;
    innerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:innerView.frame];
    shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowView.bounds cornerRadius:8.0f].CGPath;
//    shadowView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
////    shadowView.layer.shadowOffset = CGSizeMake(0, 2);
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    shadowView.layer.shadowOpacity = 0.3f;
//
    shadowView.tag = 500;
    shadowView.clipsToBounds = NO;
    shadowView.layer.masksToBounds = NO;
    [[shadowView layer] setShadowOffset:CGSizeMake(0, 2)];
    [[shadowView layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[shadowView layer] setShadowRadius:3.0];
    [[shadowView layer] setShadowOpacity:0.3];
    [self.view addSubview:shadowView];
    [self.view addSubview:innerView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectInset(innerView.frame, 20, 20)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.font = [UIFont systemFontOfSize:24.0];
    [self.view addSubview:self.textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIView *inner = [self.view viewWithTag:400];
    UIView *shadow = [self.view viewWithTag:500];
    shadow.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:inner.bounds cornerRadius:8.0f].CGPath;
}

- (void)cancel:(id)sender
{
    if (self.delegate)
    {
        [self.delegate composeViewControllerWasCancelled:self];
    }
}

- (void)send:(id)sender
{
    if (self.delegate)
    {
        [self.delegate composeViewController:self didSendMessage:self.textView.text];
    }
}

//- (void)composeViewControllerWasCancelled:(RHComposeViewController *)viewController;
//- (void)composeViewController:(RHComposeViewController *)viewController didSendMessage:(NSString *)message;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
