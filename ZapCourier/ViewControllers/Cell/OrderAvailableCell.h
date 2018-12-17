//
//  OrderAvailableCell.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelColor.h"

@interface OrderAvailableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;

@property (weak, nonatomic) IBOutlet UILabel *lbOrderId;
@property (weak, nonatomic) IBOutlet UILabel *lbReturnTrip;
@property (weak, nonatomic) IBOutlet LabelColor *lbSize;
@property (weak, nonatomic) IBOutlet LabelColor *lbPickUp;
@property (weak, nonatomic) IBOutlet LabelColor *lbDropOff;
@property (weak, nonatomic) IBOutlet LabelColor *lbDistance;

@property (weak, nonatomic) IBOutlet UIView *viewLeft;
@property (weak, nonatomic) IBOutlet UIView *viewRight;



- (void)configCell:(OOrderAvailable*)order;

@end
