//
//  VCMyRewardsCell.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "MyRewardsCell.h"

@implementation MyRewardsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellRewards:(ORewards*)order
{
    self.lbTime.text = [self stringFromDate:order.created];
    self.lbPrice.text = order.amount;
}

- (NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"MMM dd, yyyy";
    format.timeZone = [NSTimeZone defaultTimeZone];
    return [format stringFromDate:date];
}

@end
