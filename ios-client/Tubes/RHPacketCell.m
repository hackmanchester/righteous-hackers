//
//  RHPacketCell.m
//  Tubes
//
//  Created by James Frost on 28/10/2012.
//  Copyright (c) 2012 Righteous Hackers. All rights reserved.
//

#import "RHPacketCell.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define ARC4RANDOM_MAX      0x100000000

@interface RHPacketCell ()
@property (nonatomic, strong) UIImageView *pipeFront;
@end

@implementation RHPacketCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pipe_back.png"]];
        self.backgroundView.contentMode = UIViewContentModeCenter;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,140,44)];
        self.label.font = [UIFont boldSystemFontOfSize:14.0f];
        self.label.backgroundColor = [UIColor whiteColor];
        self.label.layer.cornerRadius = 8.0f;
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        
        double val = ((double)arc4random() / ARC4RANDOM_MAX);
        CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS((val * 4)-2));
        CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(2.0));
        
        self.label.transform = leftWobble;  // starting point

//        [UIView animateWithDuration:0.125 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^{
//            self.label.transform = rightWobble;
//        }completion:^(BOOL finished){
//        }];
        
        self.pipeFront = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pipes.png"]];
        self.pipeFront.contentMode = UIViewContentModeCenter;
        self.pipeFront.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.pipeFront];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.pipeFront.frame = self.bounds;
    self.label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
