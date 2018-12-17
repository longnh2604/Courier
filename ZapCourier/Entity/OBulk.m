//
//  OBulk.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/26/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OBulk.h"

@implementation OBulk

+ (NSString *)primaryKey {
    return @"bid";
}

+ (NSString*)convertToGeoJSON:(CGFloat)lat lon:(CGFloat)lon{
    return [NSString stringWithFormat:@"{\"type\": \"Point\",\"coordinates\":[%f,%f]}",lon,lat];
}

+ (void)deleteAllBulkOrder{
    RLMResults *rs = [OBulk allObjects];
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (OBulk *o in rs) {
        [realm beginWriteTransaction];
        [realm deleteObject:o];
        [realm commitWriteTransaction];
    }
    RELOAD_MENU_LEFT
}

+ (void)deleteAllOrder
{
    [self deleteAllBulkOrder];
}


+ (OBulk*)convertToObject:(NSDictionary*)json{
    OBulk *b = [[OBulk alloc]init];
    
    b.bid = [json stringForKey:@"id"];
    b.created = [NSDate convertISO8601ToDate:[json stringForKey:@"created"]];
    b.distance = [json stringForKey:@"distance"];
    b.price = [json stringForKey:@"courier_reward"];
    b.state = [json stringForKey:@"state"];
    
    NSArray *arrPickup = [json arrayForKeyPath:@"bulkorder.pickup_position.coordinates"];
    if (arrPickup.count>1)
    {
        b.pickUpLat = [arrPickup[1] floatValue];
        b.pickUpLon = [arrPickup[0] floatValue];
    }
    b.pickUpAddress = [json stringForKeyPath:@"bulkorder.pickup_address"];
    b.pickUpPhone = [json stringForKeyPath:@"bulkorder.pickup_phone"];
    b.senderName = [json stringForKeyPath:@"bulkorder.sender_name"];
    b.senderAvatar = [json stringForKeyPath:@"bulkorder.photo"];
    b.note = [json stringForKeyPath:@"bulkorder.note"];
    b.size = [json stringForKeyPath:@"bulkorder.size"];
    
    NSArray *arOrders = [json arrayForKey:@"orders"];
    for (NSDictionary *order in arOrders) {
        [b.arOrders addObject:[OOrderAvailable convertToObject:order]];
    }
    
    return b;
}

+ (void)saveOrder:(OBulk*)order
{
    [self deleteAllBulkOrder];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [OBulk createOrUpdateInDefaultRealmWithValue:order];
    [realm commitWriteTransaction];
}

+ (OBulk*)getCurrentOrder
{
    RLMResults *rs = [OBulk allObjects];
    if (rs.count>0) {
        return rs[0];
    }else{
        return nil;
    }
}

@end
