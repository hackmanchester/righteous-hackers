//
//  RHPipeFlowLayout.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHPipeFlowLayout.h"

@implementation RHPipeFlowLayout

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    CGSize size = [self collectionView].frame.size;
    attributes.center = CGPointMake(size.width * 2.0, size.height / 2.0);
    return attributes;
}

@end
