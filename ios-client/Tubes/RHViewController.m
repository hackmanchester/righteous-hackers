//
//  RHViewController.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHViewController.h"
#import "RHPipeCell.h"
#import "Message.h"
#import "PTPusherAPI.h"
#import "RHComposeViewController.h"
#import "RHPacketCell.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RHViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *messageIds;
@property (nonatomic, strong) NSMutableDictionary *messageDict;
@end

@implementation RHViewController

- (id)init
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.navigationItem.title = @"Tubes";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(compose:)];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
//        self.fetchedResultsController = [[RHPusherManager sharedInstance] fetchedResultsControllerForMessageIds];
//        self.fetchedResultsController.delegate = self;
//        
//        NSError *error;
//        BOOL success = [self.fetchedResultsController performFetch:&error];
        
        [[RHPusherManager sharedInstance] setDelegate:self];
        
        self.messageDict = [@{} mutableCopy];
        self.messageIds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"office.png"]];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[RHPacketCell class] forCellReuseIdentifier:@"PipeCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)modelChanged:(NSNotification *)notification
{
  //  self.messageIds = [[RHPusherManager sharedInstance] listOfMessageIds];

    //[self.tableView reloadData];
}

- (void)compose:(id)sender
{
    RHComposeViewController *viewController = [[RHComposeViewController alloc] init];
    viewController.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    nvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)composeViewControllerWasCancelled:(RHComposeViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)composeViewController:(RHComposeViewController *)viewController didSendMessage:(NSString *)message
{
    [[RHPusherManager sharedInstance] sendMessage:message];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pusherManagerDidReceiveMessage:(Message *)message
{
    if ([self.messageIds containsObject:message.messageId])
    {
        [self.messageDict[message.messageId] insertObject:message atIndex:0];
        
        NSInteger idx = [self.messageIds indexOfObject:message.messageId];
//        RHPipeCell *cell = (RHPipeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:idx]];
//        [cell addMessage:message];
        
        [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:0 inSection:idx] ] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {
        [self.messageDict setObject:[@[ message ] mutableCopy] forKey:message.messageId];
        [self.messageIds addObject:message.messageId];
        
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.messageIds count] - 1]
                      withRowAnimation:UITableViewRowAnimationBottom];
    }
    
//    NSLog(@"MessageIds: %@", self.messageIds);
//    NSLog(@"Messages: %@", self.messageDict);
}

/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationBottom];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationBottom];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationBottom];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - Table View
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.messageIds count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *messageId = self.messageIds[section];
    
    return [self.messageDict[messageId] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 170.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RHPacketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PipeCell" forIndexPath:indexPath];
    
//    Message *managedObject = (Message *)[self.fetchedResultsController objectAtIndexPath:indexPath];

    NSString *messageId = self.messageIds[indexPath.section];

    Message *message = self.messageDict[messageId][indexPath.row];
    
//    NSLog(@"Message: %@", message);
    
    if (message.target)
        cell.label.text = message.target;
    else if (message.sender)
        cell.label.text = message.sender;
//c
//    if (!cell.messages)
//        cell.messages = messages;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RHPacketCell *packetCell = (RHPacketCell *)cell;
    
    NSString *messageId = self.messageIds[indexPath.section];
    
    Message *message = self.messageDict[messageId][indexPath.row];
    
    switch (message.type) {
        case kMessageTypeInput:
            packetCell.label.backgroundColor = UIColorFromRGB(0xAAC9DB);
            break;
        case kMessageTypeOutput:
            packetCell.label.backgroundColor = UIColorFromRGB(0xDCDEA0);
            break;
        case kMessageTypeProcessing:
            packetCell.label.backgroundColor = UIColorFromRGB(0xDEB694);
            break;
            
        case kMessageTypeFinished:
            packetCell.label.backgroundColor = UIColorFromRGB(0x9ED58C);
            break;
        default:
            break;
    }
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.messageIds[section];
}

@end