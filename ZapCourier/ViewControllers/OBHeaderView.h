//
//  OBHeaderView.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/29/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *noOrder;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderState;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@end
