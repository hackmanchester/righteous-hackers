//
//  RHPusherManager.h
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusher.h"

@interface RHPusherManager : NSObject <PTPusherDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSFetchedResultsController *)fetchedResultsControllerForMessageIds;
- (NSArray *)listOfMessages;
- (NSSet *)listOfMessageIds;

@end
