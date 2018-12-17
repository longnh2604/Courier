//
//  AvailableCell.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvailableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vOrder;
@property (weak, nonatomic) IBOutlet UIView *vInfo;


@property (weak, nonatomic) IBOutlet UILabel *lbCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UIImageView *imvSize;

@property (weak, nonatomic) IBOutlet UILabel *lbOrderId;
@property (weak, nonatomic) IBOutlet UILabel *lbPickUp;
@property (weak, nonatomic) IBOutlet UILabel *lbDropOff;
@property (weak, nonatomic) IBOutlet UILabel *lbTimePost;
@property (weak, nonatomic) IBOutlet UILabel *lbTypeJob;

@property (weak, nonatomic) IBOutlet UILabel *lbSize;
@property (weak, nonatomic) IBOutlet UILabel *lbDistance;

- (void)configCell:(OOrderAvailable*)order showState:(BOOL)showState;
- (void)configCellBulk:(OBulk*)bulk showState:(BOOL)showState;

@end
