//
//  RHPusherManager.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHPusherManager.h"
#import "PTPusherEvent.h"
#import "PTPusherAPI.h"
#import "Message.h"
#import "Pipeline.h"

@interface RHPusherManager ()
@property (nonatomic, strong) PTPusher *pusher;
@end

@implementation RHPusherManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
    if (self = [super init])
    {
        self.pusher = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:NO];
        [self.pusher connect];
        
        // log all events received, regardless of which channel they come from
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:self.pusher];
        
        [self.pusher subscribeToChannelNamed:@"messages"];
        [self.pusher bindToEventNamed:@"output" handleWithBlock:^(PTPusherEvent *event) {
//            NSLog(@"Received pusher output event: %@", event);
            
            [self handleEvent:event];
//            NSError *error = nil;
//            [self.managedObjectContext save:&error];
        }];
        
        [self.pusher bindToEventNamed:@"input" handleWithBlock:^(PTPusherEvent *event) {
                        [self handleEvent:event];
        }];

        [self.pusher bindToEventNamed:@"processing" handleWithBlock:^(PTPusherEvent *event) {
                        [self handleEvent:event];
        }];
        
        
        [self.pusher bindToEventNamed:@"finished" handleWithBlock:^(PTPusherEvent *event) {
            [self handleEvent:event];
        }];
    }
    return self;
}

- (void)handleEvent:(PTPusherEvent *)event
{
    Message *message = [self newMessageFromEvent:event];
    
    if (message.messageId)
    {
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(pusherManagerDidReceiveMessage:)])
            [self.delegate pusherManagerDidReceiveMessage:message];
    }
    }

}

- (void)sendMessage:(NSString *)message
{
    PTPusherAPI *push = [[PTPusherAPI alloc] initWithKey:PUSHER_API_KEY appID:PUSHER_APP_ID secretKey:PUSHER_API_SECRET];
    [push triggerEvent:@"client-input" onChannel:@"private-messages" data:@{ @"payload" : message, @"target" : @"dispatcher" } socketID:nil];
}

- (Message *)newMessageFromEvent:(PTPusherEvent *)event
{
    //Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
    //                                                 inManagedObjectContext:self.managedObjectContext];
    
    Message *message = [[Message alloc] init];
    
    NSDictionary *data = (NSDictionary *)event.data;
    
    NSLog(@"Event name: %@", event.name);
    
    if ([event.name isEqualToString:@"input"])
        message.type = kMessageTypeInput;
    else if ([event.name isEqualToString:@"output" ])
        message.type = kMessageTypeOutput;
    else if ([event.name isEqualToString: @"processing"])
        message.type = kMessageTypeProcessing;
              else if ([event.name isEqualToString:@"finished"])
        message.type = kMessageTypeFinished;
    
    
    message.messageId = data[@"id"];
    message.payload = data[@"payload"];
    
    if ([[data allKeys] containsObject:@"target"])
        message.target = data[@"target"];

    if ([[data allKeys] containsObject:@"sender"])
        message.sender = data[@"sender"];
    
    return message;
}


#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
//    NSLog(@"[pusher] Received event %@", event);
}

#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSArray *)listOfPipelines
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Pipeline" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.propertiesToFetch = @[ @"messageId" ];
    [request setResultType:NSDictionaryResultType];
    request.returnsDistinctResults = YES;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"messageId" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    
    return array;
}

- (NSFetchedResultsController *)fetchedResultsControllerForMessageIds
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Configure the request's entity, and optionally its predicate.
    fetchRequest.entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
//    [fetchRequest setResultType:NSDictionaryResultType];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"messageId"]];

    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:context
                                              sectionNameKeyPath:nil
                                              cacheName:@"MessageIdCache"];
    
    return controller;
}


//- (NSSet *)listOfMessageIds
//{
//    NSManagedObjectContext *moc = [self managedObjectContext];
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
//    
//    NSFetchRequest *request = [[NSFetchRequest ]]
//}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
