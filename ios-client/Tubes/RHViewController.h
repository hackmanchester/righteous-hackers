//
//  RHViewController.h
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHPusherManager.h"
#import "RHComposeViewController.h"

@interface RHViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RHPusherManagerDelegate, RHComposeViewControllerDelegate>

@end
