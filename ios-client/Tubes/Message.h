//
//  Message.h
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * target;
@property (nonatomic, retain) NSString * sender;

@end
