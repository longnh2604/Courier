//
//  MenuCell.m
//  Delivery
//
//  Created by Long Nguyen on 12/29/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "MenuCell.h"

#define bgColorMenuActive           0xe1f5fe
#define colorTextMenuActive         0x77bce4

#define bgColorMenuInActive         0xffffff
#define colorTextMenuInActive       0x2f2f2f


@implementation MenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setMenuActive:(BOOL)active menu:(NSString*)name icon:(NSString*)icon{
    self.isActive = active;
    self.lbTitle.text = name;
    if (active) {
        self.imvIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active",icon]];
        self.lbBg.backgroundColor = UIColorFromRGB(bgColorMenuActive);
        self.lbTitle.textColor = UIColorFromRGB(colorTextMenuActive);
    }else{
        self.imvIcon.image = [UIImage imageNamed:icon];
        self.lbBg.backgroundColor = UIColorFromRGB(bgColorMenuInActive);
        self.lbTitle.textColor = UIColorFromRGB(colorTextMenuInActive);
    }
}

@end
