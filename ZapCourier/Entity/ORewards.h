//
//  ORewards.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORewards : RLMObject

@property NSString *amount;
@property NSDate *created;
@property NSString *settled;

+ (ORewards*)convertToObject:(NSDictionary*)json;

@end
