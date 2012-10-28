//
//  RHPusherManager.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHPusherManager.h"
#import "PTPusherEvent.h"
#import "Message.h"

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
            NSLog(@"Received pusher output event: %@", event);
            
            Message *message = [self newMessageFromEvent:event];
            
            NSError *error = nil;
            [self.managedObjectContext save:&error];
        }];
        
        [self.pusher bindToEventNamed:@"input" handleWithBlock:^(PTPusherEvent *event) {
            
        }];

        [self.pusher bindToEventNamed:@"processing" handleWithBlock:^(PTPusherEvent *event) {
            
        }];
    }
    return self;
}

- (Message *)newMessageFromEvent:(PTPusherEvent *)event
{
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
                                                     inManagedObjectContext:self.managedObjectContext];
    NSDictionary *data = (NSDictionary *)event.data;
    
    message.messageId = data[@"id"];
    message.payload = data[@"payload"];
    
    return message;
}


#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    NSLog(@"[pusher] Received event %@", event);
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

- (NSArray *)listOfMessages
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
        
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
