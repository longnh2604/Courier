//
//  OrderAvailableWAController.h
//  ZapCourier
//
//  Created by Long Nguyen on 2/1/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "NotificationController.h"

@interface OrderAvailableWAController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *WATableview;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lblTableNote;

@end
