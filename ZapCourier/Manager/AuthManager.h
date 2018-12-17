//
//  AuthManager.h
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthManager : NSObject

+ (AuthManager *)shared;

- (void)login:(NSString*)token;
- (void)logout;
- (void)initLogin;
- (NSString*)token;
- (NSString*)getAuthTime;
- (NSString*)getTimeResendCode;

- (void)saveBrainTreeToken:(NSString*)token;
- (NSString*)getBrainTreeToken;
+ (void)saveWaitingTimeTotal:(int)secondsWaitingTotal;
+ (int)getWaitingTimeTotal;
+ (void)saveLatestWaitingTime:(long long)latestWaitingTime;
+ (long long)getLatestWaitingTime;
+ (void)saveTimeRemainingSecond:(long long)secondRemaining;
+ (int)getTimeRemainingSecond;

@end
