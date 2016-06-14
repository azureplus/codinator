//
//  ProjectCollectionViewCell.m
//  Codinator
//
//  Created by Vladimir Danila on 09/07/15.
//  Copyright © 2015 Vladimir Danila. All rights reserved.
//

#import "ProjectCollectionViewCell.h"



@implementation ProjectCollectionViewCell


- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.imageView.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
    
    self.imageView.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
}


@end
