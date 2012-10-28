//
//  RHComposeViewController.h
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RHComposeViewController;

@protocol RHComposeViewControllerDelegate <NSObject>
- (void)composeViewControllerWasCancelled:(RHComposeViewController *)viewController;
- (void)composeViewController:(RHComposeViewController *)viewController didSendMessage:(NSString *)message;
@end

@interface RHComposeViewController : UIViewController
@property (nonatomic, weak) id <RHComposeViewControllerDelegate> delegate;
@end
