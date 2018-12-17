//
//  AvailableCell.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "AvailableCell.h"

@implementation AvailableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configCell:(OOrderAvailable*)order showState:(BOOL)showState{
    if (showState){
        self.lbOrderId.font = [UIFont systemFontOfSize:16];
        if ([order.state isEqualToString:stateKeyCompleted]) {
            //
            self.lbOrderId.textColor = UIColorFromRGB(clBlue);
        }else if ([order.state isEqualToString:stateKeyCancelled] || [order.state isEqualToString:stateKeyCourierCancelled] || [order.state isEqualToString:stateKeyAdminCancelled]){
            self.lbOrderId.textColor = UIColorFromRGB(clPink);
        }else{
            self.lbOrderId.textColor = UIColorFromRGB(clPink);
        }
        self.lbOrderId.text = [NSString stringWithFormat:@"#%@ - %@",order.oid,[Util convertStateOrder:order.state.uppercaseString]];
    }else{
        self.lbOrderId.text = [NSString stringWithFormat:@"Order #%@",order.oid];
    }
    self.lbTimePost.text = [NSString stringWithFormat:@"Posted at %@",[self stringFromDate:order.created withFormat:@"HH:mm MMM dd, yyyy"]];
    
    if (order.isReturnTrip)
    {
        self.lbTypeJob.text = @"RETURN TRIP";
    }
    else
    {
        self.lbTypeJob.text = @"SINGLE DELIVERY";
    }
    
    //view 2
    if ([stateKeyCancelled isEqualToString:order.state ]|| [stateKeyInOffice isEqualToString:order.state] || [stateKeyAdminCancelled isEqualToString:order.state])
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
    
    if (order.pickupAddress.length>0) {
        self.lbPickUp.text = order.pickupAddress;
    }
    
    if (order.dropoffAddress.length>0) {
        self.lbDropOff.text = order.dropoffAddress;
    }
    
    self.lbSize.text = order.size;
    self.imvSize.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@",order.size.lowercaseString]];
    self.imvSize.image = [self.imvSize.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imvSize.tintColor = UIColorFromRGB(clGray2);
    self.lbDistance.text = [NSString stringWithFormat:@"%.2f km",(order.distance.floatValue/1000)];
}

- (void)configCellBulk:(OBulk *)bulk showState:(BOOL)showState
{
    if (showState){
        self.lbOrderId.font = [UIFont systemFontOfSize:16];
        if ([bulk.state isEqualToString:stateKeyCompleted]) {
            //
            self.lbOrderId.textColor = UIColorFromRGB(clBlue);
        }else if ([bulk.state isEqualToString:stateKeyCancelled] || [bulk.state isEqualToString:stateKeyCourierCancelled] || [bulk.state isEqualToString:stateKeyAdminCancelled]){
            self.lbOrderId.textColor = UIColorFromRGB(clPink);
        }else{
            self.lbOrderId.textColor = UIColorFromRGB(clPink);
        }
        self.lbOrderId.text = [NSString stringWithFormat:@"#B%@ - %@",bulk.bid,[Util convertStateOrder:bulk.state.uppercaseString]];
    }else{
        self.lbOrderId.text = [NSString stringWithFormat:@"Order #B%@",bulk.bid];
    }
    self.lbTimePost.text = [NSString stringWithFormat:@"Posted at %@",[self stringFromDate:bulk.created withFormat:@"HH:mm MMM dd, yyyy"]];
    self.lbTypeJob.text = @"BULK JOBS";
    
    
    //view 2
    self.lbPrice.text = bulk.price;
    
    if (bulk.pickUpAddress.length>0) {
        self.lbPickUp.text = bulk.pickUpAddress;
    }
    self.lbDropOff.text = [NSString stringWithFormat:@"%d destinations",(int)bulk.arOrders.count];
    
    self.lbSize.text = @"PARCELS";
    self.imvSize.image = [UIImage imageNamed:@"icon_bullkjobs"];
    self.imvSize.image = [self.imvSize.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imvSize.tintColor = UIColorFromRGB(clGray2);
    self.lbDistance.text = [NSString stringWithFormat:@"%.2f km",(bulk.distance.floatValue/1000)];
}

- (NSString*)stringFromDate:(NSDate*)date withFormat:(NSString*)fm{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = fm;
    format.timeZone = [NSTimeZone defaultTimeZone];
    return [format stringFromDate:date];
}

@end
