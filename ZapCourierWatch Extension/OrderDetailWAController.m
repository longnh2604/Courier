//
//  OrderDetailWAController.m
//  ZapCourier
//
//  Created by Long Nguyen on 2/3/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OrderDetailWAController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface OrderDetailWAController ()<WCSessionDelegate>

@end

@implementation OrderDetailWAController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setLayoutWithMessage:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setLayoutWithMessage:(NSDictionary*)message
{
    if (message)
    {
        self.objMessage = message;
        [self setTitle:[NSString stringWithFormat:@"#%@",[message objectForKey:@"oid"]]];
        [self.orderPrice setText:[NSString stringWithFormat:@"$%@",[message objectForKey:@"price"]]];
        [self.orderPickup setText:[NSString stringWithFormat:@"      %@",[message objectForKey:@"pickup"]]];
        [self.orderDropoff setText:[NSString stringWithFormat:@"      %@",[message objectForKey:@"dropoff"]]];
        
        if ([[message objectForKey:@"return"]isEqualToString:@"1"])
        {
            [self.orderReturn setHidden:NO];
        }
        else
        {
            [self.orderReturn setHidden:YES];
        }
    }
}

- (IBAction)onTakeOrder {
    
    [[WCSession defaultSession] sendMessage:@{@"order":[self.objMessage objectForKey:@"oid"],@"action":@"take"} replyHandler:nil errorHandler:^(NSError * _Nonnull error)
    {
        NSLog(@"error = %@",error.localizedDescription);
    }];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    if(message)
    {
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
        NSString *action = [message objectForKey:@"action"];
        if ([action isEqualToString:@"assigned"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"OrderAssignWAController"] contexts:@[message]];
        }else if ([action isEqualToString:@"nonLogin"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"SplashWAController"] contexts:@[message]];
        }
    }
}

@end



