//
//  Message.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "Message.h"


@implementation Message

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Message id:%@ payload:%@ target:%@ sender:%@>", self.messageId, self.payload, self.target, self.sender];
}

@end
