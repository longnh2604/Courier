//
//  TabView.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "TabView.h"

#define speedAnimationSwitch        0.3
#define indexBulkDelivery           0
#define indexSingleDelivery         1

@implementation TabView



- (IBAction)selectedBulkButton:(id)sender{
    [self switchLabelSelectedToPosition:indexBulkDelivery];
}

- (IBAction)selectedSingleButton:(id)sender{
    [self switchLabelSelectedToPosition:indexSingleDelivery];
}

- (void)switchToBulkDelivery{
    [self.btnBulk setTitleColor:UIColorFromRGB(clBlue) forState:UIControlStateNormal];
    [self.btnSingle setTitleColor:UIColorFromRGB(0xbfebfe) forState:UIControlStateNormal];
    self.selected = indexBulkDelivery;
}
- (void)switchToSingleDelivery{
    [self.btnBulk setTitleColor:UIColorFromRGB(0xbfebfe) forState:UIControlStateNormal];
    [self.btnSingle setTitleColor:UIColorFromRGB(clBlue) forState:UIControlStateNormal];
    self.selected = indexSingleDelivery;
}

- (void)switchLabelSelectedToPosition:(int)position{
    [self.delegate tabViewSelectedButtonAtIndex:position];
}

- (void)updateViewWhenScrolling:(CGPoint)offset{
    [self.lbSelected setX:(offset.x/2)];
    [self needsUpdateConstraints];
    if (offset.x<(SCREEN_WIDTH/2)) {
        [self switchToBulkDelivery];
    }else if (offset.x>(SCREEN_WIDTH/2)){
        [self switchToSingleDelivery];
    }
}


@end
