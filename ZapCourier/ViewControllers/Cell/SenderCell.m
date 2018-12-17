//
//  SenderCell.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "SenderCell.h"

@implementation SenderCell

- (void)awakeFromNib {
    // Initialization code
    self.imvAvatar.layer.cornerRadius = self.imvAvatar.width/2;
    self.imvAvatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
