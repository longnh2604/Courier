//
//  BridgeWAController.m
//  ZapCourier
//
//  Created by Long Nguyen on 2/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "BridgeWAController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface BridgeWAController ()<WCSessionDelegate>

@end

@implementation BridgeWAController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



