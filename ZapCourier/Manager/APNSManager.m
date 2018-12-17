//
//  APNSManager.m
//  Delivery
//
//  Created by Long Nguyen on 1/8/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "APNSManager.h"

@implementation APNSManager

+ (APNSManager *)shared {
    static APNSManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[APNSManager alloc] init];
    });
    
    return _shared;
}

- (void)registerAPNS{
#if !TARGET_IPHONE_SIMULATOR
    if ([UIApplication sharedApplication].isRegisteredForRemoteNotifications){
        DLog(@"isRegistered");
        [self didRegisterForRemoteNotificationsWithDeviceToken:[Util objectForKey:dvToken]];
    }else{
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // Registering for push notifications under iOS8
            UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }
#endif
}

- (void)unregisterAPNS
{
#if !TARGET_IPHONE_SIMULATOR
    [Util removeObjectForKey:dvToken];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
#endif
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    if (deviceToken){
        [Util setObject:deviceToken forKey:dvToken];
        
        NSString * deviceTokenString = [[[[deviceToken description]
                                          stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                                        stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        DLog(@"the generated device token string is : %@",deviceToken);
        
        [HServiceAPI addAPNSToken:deviceTokenString];
    }
}

- (void)receiveRemoteNotification:(NSDictionary*)userInfo
{
    NSString *event = [userInfo stringForKey:@"event"];
    NSString *oid = [userInfo stringForKey:@"order_id"];
    APPSHARE.oidNotify = oid;
    
    if ([event isEqualToString:@"order_state_changed"])
    {
        NSDictionary *dicOrder = [userInfo dicForKey:@"order"];
        if (dicOrder)
        {
            NSString *state = [dicOrder stringForKey:@"state"];
            NSString *sender_cancel_note = [dicOrder stringForKey:@"sender_cancel_note"];
            if ([state isEqualToString:stateKeyCancelled])
            {
                [APPSHARE checkActiveOrder:NO];
                [OOrderAvailable deleteAllOrder];
                [UIAlertView showWithTitle:@"Notice" message:sender_cancel_note handler:nil];
            }
        }
        CHANGE_STATUS_ORDER(nil)
    }
    else if ([event isEqualToString:@"new_order_available"])
    {
        if ([APPSHARE.appState isEqualToString:@"onActive"])
        {
            RELOAD_ORDER_AVAILABLE
        }
        else if([APPSHARE.appState isEqualToString:@"onInactive"])
        {
            if (APPSHARE.userLogin.activeOrder == true)
            {
                [UIAlertView showWithTitle:@"Notice" message:@"You have one active order !" handler:nil];
            }
            else
            {
                [APPSHARE showFromNotification:APPSHARE.oidNotify];
            }
        }
        else if ([APPSHARE.appState isEqualToString:@"onBackground"])
        {
            
        }
        else
        {
            [APPSHARE showFromNotification:APPSHARE.oidNotify];
        }
    }
    else if ([event isEqualToString:@"new_bulkorder_available"])
    {
        RELOAD_ORDER_AVAILABLE
    }
    else if ([event isEqualToString:@"basket_state_changed"])
    {
        NSString *bState = [userInfo stringForKey:@"basket_state"];
        NSString *bCancelReason = [userInfo stringForKey:@"sender_cancel_reason"];
        if ([bState isEqualToString:@"CANCELLED"])
        {
            [APPSHARE checkActiveOrder:NO];
            [OBulk deleteAllOrder];
            [UIAlertView showWithTitle:@"Notice" message:bCancelReason handler:nil];
        }
        CHANGE_STATUS_ORDER(nil)
    }
}

- (void)didFailToRegisterForRemoteNoficationWithError:(NSError*)error{
    DLog(@"error = %@",error.localizedDescription);
}

@end
