//
//  RHPipeCell.h
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHPipeCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSInteger numberOfPipes;
@property (strong, nonatomic) UICollectionView *collectionView;

@end
