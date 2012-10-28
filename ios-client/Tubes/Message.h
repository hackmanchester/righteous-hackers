//
//  Message.h
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>

//@class Pipeline;

enum MessageType {
    kMessageTypeInput = 0,
    kMessageTypeOutput,
    kMessageTypeProcessing,
    kMessageTypeFinished
    };

@interface Message : NSObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * target;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * payload;
@property (nonatomic) NSInteger type;
//@property (nonatomic, retain) Pipeline *pipeline;

@end
