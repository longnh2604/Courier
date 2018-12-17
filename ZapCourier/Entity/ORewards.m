//
//  ORewards.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "ORewards.h"

@implementation ORewards

+ (ORewards*)convertToObject:(NSDictionary*)json
{
    ORewards *order = [[ORewards alloc]init];
    
    order.created = [NSDate convertISO8601ToDate:[json stringForKey:@"created"]];
    order.amount = [json stringForKey:@"amount"];
    order.settled = [json stringForKey:@"settled"];
    
    return order;
}

@end
