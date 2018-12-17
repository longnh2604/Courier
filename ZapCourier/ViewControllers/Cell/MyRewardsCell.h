//
//  VCMyRewardsCell.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelColor.h"

@interface MyRewardsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;

@property (weak, nonatomic) IBOutlet UIView *viewLeft;
@property (weak, nonatomic) IBOutlet UIView *viewRight;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;

- (void)configCellRewards:(ORewards*)reward;

@end
