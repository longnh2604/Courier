//
//  HistoryCell.m
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCell:(OOrderAvailable*)order
{
    if ([stateKeyCancelled isEqualToString:order.state ] || [stateKeyAdminCancelled isEqualToString:order.state])
    {
        self.lbPrice.text = @"0.00";
    }
    else
    {
        NSArray *arr = [order.price componentsSeparatedByString:@"."];
        if (arr.count==2) {
            NSString *t1 = [arr objectAtIndex:1];
            
            if (t1.length == 1)
            {
                self.lbPrice.text = [NSString stringWithFormat:@"%@0",order.price];
            }
            else if (t1.length == 2)
            {
                self.lbPrice.text = order.price;
            }
        }else{
            self.lbPrice.text = order.price;
        }
    }
 
    [self.lbSize setText:[NSString stringWithFormat:@"Size: %@",order.size] withbold:@"Size:"];
    
    if (order.pickupAddressDetail.length>0) {
        self.lbPickUp.text = [NSString stringWithFormat:@"%@\n%@",order.pickupAddress,order.pickupAddressDetail];
        [self sethighLight:order.pickupAddressDetail withLabel:self.lbPickUp];
    }else{
        self.lbPickUp.text = order.pickupAddress;
    }
    if (order.dropoffAddressDetail.length>0) {
        self.lbDropOff.text = [NSString stringWithFormat:@"%@\n%@",order.dropoffAddress,order.dropoffAddressDetail];
        [self sethighLight:order.dropoffAddressDetail withLabel:self.lbDropOff];
    }else{
        self.lbDropOff.text = order.dropoffAddress;
    }
    
    self.lbOrderId.text = [NSString stringWithFormat:@"#%@ %@",order.oid,[Util convertStateOrder:order.state.uppercaseString]];
    if ([order.state isEqualToString:stateKeyCompleted]) {
        //
        self.lbOrderId.textColor = UIColorFromRGB(clBlue);
    }else if ([order.state isEqualToString:stateKeyCancelled] || [order.state isEqualToString:stateKeyCourierCancelled] || [order.state isEqualToString:stateKeyAdminCancelled]){
        self.lbOrderId.textColor = UIColorFromRGB(clPink);
    }else{
        self.lbOrderId.textColor = UIColorFromRGB(clPink);
    }
    
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
    
    self.lbTime.text = [self stringFromDate:order.created];
    [self.lbDistance setText:[NSString stringWithFormat:@"Distance: %.2f km",(order.distance.floatValue/1000)] withbold:@"Distance:"];
}

- (NSString*)stringFromDate:(NSDate*)date{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"MMM dd, yyyy";
    format.timeZone = [NSTimeZone defaultTimeZone];
    return [format stringFromDate:date];
}
-(void)sethighLight:(NSString*)highLight withLabel:(UILabel*)label{
    
    NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:label.text];
    
    [coloredText addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x6b6b6b) range:[label.text rangeOfString:highLight]];
    label.attributedText = coloredText;
}

@end
