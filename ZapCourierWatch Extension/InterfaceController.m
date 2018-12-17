//
//  InterfaceController.m
//  ZapCourierWatch Extension
//
//  Created by Long Nguyen on 2/1/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController()<WCSessionDelegate>
@end


@implementation InterfaceController

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

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    
    if(message)
    {
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
        NSString *action = [message objectForKey:@"action"];
        if ([action isEqualToString:@"login"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"OrderAvailableWAController"] contexts:@[message]];
        }else if ([action isEqualToString:@"assigned"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"OrderAssignWAController"] contexts:@[message]];
        }else if ([action isEqualToString:@"nonLogin"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"SplashWAController"] contexts:@[message]];
        }
    }
}

@end



