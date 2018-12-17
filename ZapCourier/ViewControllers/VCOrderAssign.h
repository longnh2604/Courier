//
//  VCOrderAssign.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCOrderAssign : BaseView

@property (nonatomic, strong) OOrderAvailable *currentOrder;
@property (nonatomic, assign) BOOL isFromHistory;
@property (strong, nonatomic) IBOutlet UIView *popTimeClock;
@property (weak, nonatomic) IBOutlet UIButton *btnDismiss;

@end
