//
//  OrderDetailWAController.h
//  ZapCourier
//
//  Created by Long Nguyen on 2/3/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface OrderDetailWAController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *orderPrice;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *orderReturn;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *orderPickup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *orderDropoff;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *btnTakeOrder;

@property (nonatomic, strong) NSDictionary *objMessage;

- (IBAction)onTakeOrder;

@end
