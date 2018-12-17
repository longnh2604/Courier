//
//  OrderHelper.h
//  Delivery
//
//  Created by Long Nguyen on 1/8/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderHelper : NSObject

+ (BOOL)isShowConfirmCode:(OOrderAvailable*)order;
+ (NSString*)showConfirmCodeWithStatus:(OOrderAvailable*)order;
+ (NSString*)showNoteConfirmCode:(OOrderAvailable*)order;


+ (BOOL)isShowTimerDelivering:(OOrderAvailable*)order;
+ (NSString*)calculatorTimerStart:(OOrderAvailable*)order;

+ (BOOL)checkNeedRefreshOrder:(OOrderAvailable*)order;
+ (BOOL)checkHiddenAllButton:(OOrderAvailable*)order history:(BOOL)history;

@end
