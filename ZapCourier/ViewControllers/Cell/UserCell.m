//
//  UserCell.m
//  Delivery
//
//  Created by Long Nguyen on 12/29/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

- (void)awakeFromNib {
    // Initialization code
    self.imvAvatar.layer.cornerRadius = self.imvAvatar.width/2;
    self.imvAvatar.layer.masksToBounds = YES;
    self.imvAvatar.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
    self.imvAvatar.layer.borderWidth = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)showAvatar:(BOOL)show{
    self.lbName.hidden = !show;
    self.lbPhone.hidden = !show;
    self.imvAvatar.hidden = !show;
}

@end
