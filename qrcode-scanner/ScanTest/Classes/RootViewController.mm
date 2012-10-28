// -*- Mode: ObjC; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
/*
 * Copyright 2010-2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "RootViewController.h"
#import "PTPusherAPI.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"

#ifndef ZXQR
#define ZXQR 1
#endif

#if ZXQR
#import "QRCodeReader.h"
#endif

#ifndef ZXAZ
#define ZXAZ 0
#endif

#if ZXAZ
#import "AztecReader.h"
#endif

#define PUSHER_API_KEY    @"afefd11a8f69dd2a425d"
#define PUSHER_API_SECRET @"6f034e7a52ece851ea77"
#define PUSHER_APP_ID     @"30507"


@interface RootViewController()
@property (nonatomic, retain) NSMutableDictionary *eventData;
@property (nonatomic, strong) PTPusher *pusher;
@end


@implementation RootViewController
@synthesize resultsView;
@synthesize resultsToDisplay;
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setTitle:@"ZXing"];
  [resultsView setText:resultsToDisplay];
    
   self.pusher = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:nil encrypted:NO];
    [self.pusher connect];
    
    // log all events received, regardless of which channel they come from
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:self.pusher];
    
    [self.pusher subscribeToChannelNamed:@"messages"];
    
    [self.pusher bindToEventNamed:@"input" handleWithBlock:^(PTPusherEvent *event) {
        NSString *target = (NSString *)event.data[@"target"];
        if ([target isEqualToString:@"qrcode"])
            self.eventData = [event.data mutableCopy];
    }];

    [self scanPressed:self];
}

- (IBAction)scanPressed:(id)sender {
	
  ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];

  NSMutableSet *readers = [[NSMutableSet alloc ] init];

#if ZXQR
  QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
  [readers addObject:qrcodeReader];
  [qrcodeReader release];
#endif
    
#if ZXAZ
  AztecReader *aztecReader = [[AztecReader alloc] init];
  [readers addObject:aztecReader];
  [aztecReader release];
#endif
    
  widController.readers = readers;
  [readers release];
    
  NSBundle *mainBundle = [NSBundle mainBundle];
  widController.soundToPlay =
    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
  [self presentModalViewController:widController animated:YES];
  [widController release];
}

#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
  self.resultsToDisplay = result;
  if (self.isViewLoaded) {
    [resultsView setText:resultsToDisplay];
    [resultsView setNeedsDisplay];
      
//      NSString *data = [NSString stringWithFormat:@"{ \"id\":12345, \"payload\":\"%@\" }", result];
//      NSData *thedata = [data dataUsingEncoding:NSUTF8StringEncoding];
//      
//      NSError *error;
//      NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:thedata options:0 error:&error];
      
      if (self.eventData)
      {
          self.eventData[@"payload"] = result;
          self.eventData[@"sender"] = @"qrcode";
          
          PTPusherAPI *push = [[PTPusherAPI alloc] initWithKey:PUSHER_API_KEY appID:PUSHER_APP_ID secretKey:PUSHER_API_SECRET];
          [push triggerEvent:@"output" onChannel:@"messages" data:self.eventData socketID:nil];
      }

  }
  [self dismissModalViewControllerAnimated:NO];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
  self.resultsView = nil;
}

- (void)dealloc {
  [resultsView release];
  [resultsToDisplay release];
  [super dealloc];
}


@end

