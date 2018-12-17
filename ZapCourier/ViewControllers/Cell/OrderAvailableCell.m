//
//  OrderAvailableCell.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OrderAvailableCell.h"

@implementation OrderAvailableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCell:(OOrderAvailable*)order
{
    if ([stateKeyCancelled isEqualToString:order.state ]|| [stateKeyInOffice isEqualToString:order.price])
    {
        self.lbPrice.text = @"0.00";
    }
    else
    {
        NSString *str = order.price;
        NSArray *arr = [str componentsSeparatedByString:@"."];
        NSString *t1 = [arr objectAtIndex:1];
        
        if (t1.length == 1)
        {
            self.lbPrice.text = [NSString stringWithFormat:@"%@0",order.price];
        }
        if (t1.length == 2)
        {
            self.lbPrice.text = order.price;
        }
    }
    
    [self.lbSize setText:[NSString stringWithFormat:@"Size: %@",order.size] withbold:@"Size:"];
    
    if (order.pickupAddress.length>0) {
        [self.lbPickUp setText:[NSString stringWithFormat:@"From: %@",order.pickupAddress] withbold:@"From:"];
    }
    
    if (order.dropoffAddress.length>0) {
        [self.lbDropOff setText:[NSString stringWithFormat:@"To: %@",order.dropoffAddress] withbold:@"To:"];
    }
    
    self.lbOrderId.text = [NSString stringWithFormat:@"#%@",order.oid];
    
    self.lbReturnTrip.layer.cornerRadius = 5.0;
    self.lbReturnTrip.layer.masksToBounds = YES;
    
    if (order.isReturnTrip)
    {
        self.lbReturnTrip.hidden = NO;
    }
    else
    {
        self.lbReturnTrip.hidden = YES;
    }
    
    [self.lbDistance setText:[NSString stringWithFormat:@"Distance: %.2f km",(order.distance.floatValue/1000)] withbold:@"Distance:"];
}

- (NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"MMM dd, yyyy";
    format.timeZone = [NSTimeZone defaultTimeZone];
    return [format stringFromDate:date];
}

@end
