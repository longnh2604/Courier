//
//  OrderAssignWAController.h
//  ZapCourier
//
//  Created by Long Nguyen on 2/3/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface OrderAssignWAController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *imvAvatar;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lbName;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lbCode;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lbOrderStatus;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *btnCall;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *groupStatus;

@property (nonatomic, strong) NSDictionary *objMessage;
@property (nonatomic, strong) NSString *tempOState;

@end
