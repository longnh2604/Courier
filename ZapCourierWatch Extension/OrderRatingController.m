//
//  OrderRatingController.m
//  ZapCourier
//
//  Created by Long Nguyen on 2/1/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OrderRatingController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface OrderRatingController ()<WCSessionDelegate>
{
   
}
@end

@implementation OrderRatingController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        [[WCSession defaultSession] sendMessage:@{@"action":@"checkOrder"}
                                   replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
                                       NSLog(@"error = %@",error.localizedDescription);
                                   }];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



