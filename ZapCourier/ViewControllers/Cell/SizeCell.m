//
//  SizeCell.m
//  Delivery
//
//  Created by Long Nguyen on 12/29/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "SizeCell.h"



#define colorBgSize             0xf7f7f7
#define colorBgSizeActive       0xe1f5fe

#define colorBgPrice            0xcccccc
#define colorBgPriceActive      0xb3e5fc
#define colorTextPrice          0xffffff
#define colorTextPriceActive    0x77bce4

#define colorTextCurrency       0xffffff
#define colorTextCurrencyActive 0x0098fc

#define colorTextActive         0x0098fc
#define colorText               0x999999


@implementation SizeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configCell:(BOOL)active info:(NSDictionary*)info withPrice:(NSString*)price{
    self.lbPack.text = [info stringForKey:@"pack"];
    self.lbPrice.text = price;
    self.lbSize.text = [info stringForKey:@"size"];
    self.lbWeight.text = [info stringForKey:@"weight"];
    self.lbGuide.text = [info stringForKey:@"guide"];
    
    
    if (active) {
        self.imvSize.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active",[info stringForKey:@"image"]]];
        
        self.lbWeight.textColor = UIColorFromRGB(colorTextActive);
        self.lbCurrency.textColor = UIColorFromRGB(colorTextActive);
        self.lbSize.textColor = UIColorFromRGB(colorTextActive);
        self.lbGuide.textColor = UIColorFromRGB(colorTextActive);
        self.lbPrice.textColor = UIColorFromRGB(colorTextPriceActive);
        self.lbCurrency.textColor = UIColorFromRGB(colorTextCurrencyActive);
        self.lbPack.textColor = UIColorFromRGB(colorTextActive);
        self.vPack.backgroundColor = UIColorFromRGB(colorBgSizeActive);
        self.vPrice.backgroundColor = UIColorFromRGB(colorBgPriceActive);
        
    }else{
        self.imvSize.image = [UIImage imageNamed:[info stringForKey:@"image"]];
        
        self.lbWeight.textColor = UIColorFromRGB(colorText);
        self.lbCurrency.textColor = UIColorFromRGB(colorText);
        self.lbSize.textColor = UIColorFromRGB(colorText);
        self.lbGuide.textColor = UIColorFromRGB(colorText);
        self.lbPrice.textColor = UIColorFromRGB(colorTextPrice);
        self.lbCurrency.textColor = UIColorFromRGB(colorTextCurrency);
        self.lbPack.textColor = UIColorFromRGB(colorText);
        self.vPack.backgroundColor = UIColorFromRGB(colorBgSize);
        self.vPrice.backgroundColor = UIColorFromRGB(colorBgPrice);
    }
}

@end
