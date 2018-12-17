//
//  OBBottomCell.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/30/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBBottomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblSenderName;
@property (weak, nonatomic) IBOutlet UIButton *lblSenderPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblTypePacket;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UIImageView *imvPacket;
@property (weak, nonatomic) IBOutlet UIButton *btnSMS;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightButton;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirmDelivery;
@property (weak, nonatomic) IBOutlet UIButton *btnCantDeliver;

@end
