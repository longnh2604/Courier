//
//  DropOffCell.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "DropOffCell.h"

@implementation DropOffCell

- (void)awakeFromNib {
    // Initialization code
    self.lbNumber.layer.cornerRadius = self.lbNumber.width/2;
    self.lbNumber.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
