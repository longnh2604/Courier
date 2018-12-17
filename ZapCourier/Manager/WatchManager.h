//
//  WatchManager.h
//  ZapCourier
//
//  Created by Long Nguyen on 4/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface WatchManager : NSObject

+ (WatchManager *)shared;

- (void)enableWatchWithDelegate:(id)delegate;
- (void)sendDataToWatch:(NSArray*)orders withUserStatus:(NSString *)status;
- (void)completeOrder;
- (void)alertNewOrder;
- (void)sendStatusOrder:(OOrderAvailable *)order;
- (void)sendMessage:(NSDictionary*)meg;
- (void)getOrderAvailable;

@end
