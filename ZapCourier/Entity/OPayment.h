//
//  OPayment.h
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPayment : RLMObject

@property NSString *bin;
@property NSString *cardType;
@property NSString *cardHolderName;
@property NSString *cardDefault;
@property NSString *expirationMonth;
@property NSString *expirationYear;
@property NSString *expired;
@property NSString *imageUrl;
@property NSString *last4;
@property NSString *maskedNumber;
@property NSString *token;


+ (OPayment*)convertObject:(NSDictionary*)object;
+ (BOOL)checkExpired:(OPayment*)payment;


@end
RLM_ARRAY_TYPE(OPayment)
