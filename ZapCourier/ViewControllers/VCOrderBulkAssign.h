//
//  VCOrderBulkAssign.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCOrderBulkAssign : BaseView

@property (nonatomic, strong) OBulk *currentOrder;
@property (nonatomic, assign) BOOL isFromHistory;
@property (strong, nonatomic) IBOutlet UIView *vConfirmDelivery;
@property (strong, nonatomic) IBOutlet UIView *vInform;

@end
