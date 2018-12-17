//
//  AuthManager.m
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "AuthManager.h"


#define AuthToken                   @"AuthToken"
#define AuthTokenTimestamp          @"AuthTokenTimestamp"
#define BraintreeKey                @"BraintreeKey"
#define APNSToken                   @"APNSToken"
#define isPhoneConfirmed            @"IsPhoneConfirmed"
#define Phone                       @"Phone"
#define LastSuccessfullLoginPhone   @"LastSuccessfullLoginPhone"
#define WaitingTimeTotal            @"WaitingTimeTotal"
#define LatestWaitingTime           @"LatestWaitingTime"
#define TimeRemainingSecond           @"TimeRemainingSecond"

@implementation AuthManager

+ (AuthManager *)shared {
    static AuthManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[AuthManager alloc] init];
    });
    
    return _shared;
}

- (void)login:(NSString*)token{
    [Util setObject:token forKey:AuthToken];
    [Util setObject:[NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]] forKey:AuthTokenTimestamp];
    [self initLogin];
}

- (void)logout{
    [OUserLogin deleteAllObjects];
    APPSHARE.userLogin = nil;
    
    [OOrderAvailable deleteAllOrder];
    [OBulk deleteAllOrder];
    [[APNSManager shared] unregisterAPNS];
    
    [Util removeObjectForKey:@"workstatus"];
    [Util removeObjectForKey:AuthToken];
    [Util removeObjectForKey:AuthTokenTimestamp];
    [Util removeObjectForKey:BraintreeKey];
    [[WatchManager shared] sendMessage:@{@"action":@"nonLogin"}];
}

- (void)initLogin{
    [HServiceAPI getBrainTreeToken:^(BOOL finish, NSError *error) {
        //
    }];
//    [[LocationManager shared] startUpdating];
//    [[APNSManager shared] registerAPNS];
    [[WatchManager shared] sendMessage:@{@"action":@"login"}];
}

- (NSString*)token{
    if (![Util isNullOrNilObject:[Util objectForKey:AuthToken]]) {
        return [Util objectForKey:AuthToken];
    }else{
        return nil;
    }
}

- (void)saveBrainTreeToken:(NSString*)token{
    [Util setObject:token forKey:BraintreeKey];
}
- (NSString*)getBrainTreeToken{
    return [Util objectForKey:BraintreeKey];
}

- (NSString*)getAuthTime{
    if (![Util isNullOrNilObject:[Util objectForKey:AuthTokenTimestamp]]) {
        return [Util objectForKey:AuthTokenTimestamp];
    }else{
        return @"";
    }
}
- (NSString*)getTimeResendCode{
    if (![Util isNullOrNilObject:[Util objectForKey:timeResendCode]]) {
        return [Util objectForKey:timeResendCode];
    }else{
        return @"";
    }
}

/**
 * Upgragde for return trip function
 */
+ (void)saveWaitingTimeTotal:(int)secondsWaitingTotal {
    [Util setObject:[NSString stringWithFormat:@"%d", secondsWaitingTotal] forKey:WaitingTimeTotal];
}

+ (int)getWaitingTimeTotal {
    NSString *waitingTimeTotal = [Util objectForKey:WaitingTimeTotal];
    return (waitingTimeTotal != nil && [@"" isEqualToString:waitingTimeTotal] ? [waitingTimeTotal intValue] : 0);
}

+ (void)saveLatestWaitingTime:(long long)latestWaitingTime {
    [Util setObject:[NSString stringWithFormat:@"%lld", latestWaitingTime] forKey:LatestWaitingTime];
}

+ (long long)getLatestWaitingTime {
    NSString *latestWaitingTime = [Util objectForKey:LatestWaitingTime];
    return (latestWaitingTime != nil && [@"" isEqualToString:latestWaitingTime] ? [latestWaitingTime longLongValue] : 0);
}

+ (void)saveTimeRemainingSecond:(long long)secondRemaining {
    [Util setObject:[NSString stringWithFormat:@"%lld", secondRemaining] forKey:TimeRemainingSecond];
}

+ (int)getTimeRemainingSecond {
    NSString *secondRemaining = [Util objectForKey:TimeRemainingSecond];
    return (secondRemaining != nil && [@"" isEqualToString:secondRemaining] ? [secondRemaining intValue] : 0);
}

@end
