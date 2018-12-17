//
//  APNSManager.h
//  Delivery
//
//  Created by Long Nguyen on 1/8/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APNSManager : NSObject


+ (APNSManager *)shared;
- (void)registerAPNS;
- (void)unregisterAPNS;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)receiveRemoteNotification:(NSDictionary*)userInfo;
- (void)didFailToRegisterForRemoteNoficationWithError:(NSError*)error;

@end
