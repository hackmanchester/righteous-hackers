//
//  RHPipeCell.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHPipeCell.h"
#import "RHMessageCell.h"
#import "Message.h"
#import "RHPipeFlowLayout.h"

@implementation RHPipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UICollectionViewFlowLayout *layout = [[RHPipeFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [layout setItemSize:CGSizeMake(250, 80)];
        [layout setMinimumInteritemSpacing:0.0f];
        [layout setMinimumLineSpacing:0.0f];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        

        [self.collectionView registerClass:[RHMessageCell class] forCellWithReuseIdentifier:@"MessageCell"];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
        
        _messages = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}

- (void)setNumberOfPipes:(NSInteger)numberOfPipes
{
    _numberOfPipes = numberOfPipes;
    
//    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
//    self.scrollView.contentSize = CGSizeMake(200.0f * numberOfPipes, self.bounds.size.height);
    
//    UIView *sub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200.0f * numberOfPipes, self.bounds.size.height)];
//    sub.backgroundColor = [UIColor redColor];
//    [self.scrollView addSubview:sub];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setMessages:(NSArray *)messages
{
//    [self.collectionView performBatchUpdates:^{
//        NSInteger insertedCount = [messages count] - [_messages count];
//    
//        if (insertedCount > 0)
//        {
            _messages = [messages mutableCopy];
            
//            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//            
//            for (NSInteger i = [messages count] - insertedCount; i < [messages count]; i++) {
//                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
//            }
//            [self.collectionView insertItemsAtIndexPaths: indexPaths ];
//        }

  //  } completion:nil];

    [self.collectionView reloadData];
}

- (void)addMessage:(Message *)message
{
    [self.messages addObject:message];
//    NSLog(@"cell messages: %@", self.messages);
    [self.collectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:[self.messages count]-1 inSection:0] ]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RHMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    Message *message = self.messages[indexPath.row];
    
    cell.titleLabel.text = message.payload;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(250, 100);
}

@end
