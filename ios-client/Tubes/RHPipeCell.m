//
//  RHPipeCell.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHPipeCell.h"
#import "RHMessageCell.h"

@implementation RHPipeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [layout setItemSize:CGSizeMake(250, 100)];
        [layout setMinimumInteritemSpacing:0.f];
        [layout setMinimumLineSpacing:0.0f];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        [self.collectionView registerClass:[RHMessageCell class] forCellWithReuseIdentifier:@"MessageCell"];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RHMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    return cell;
}

@end
