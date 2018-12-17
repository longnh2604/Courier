//
//  OOrderAvailable.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OOrderAvailable.h"

@implementation OOrderAvailable

+ (NSString *)primaryKey {
    return @"oid";
}

+ (NSString*)convertToGeoJSON:(CGFloat)lat lon:(CGFloat)lon{
    return [NSString stringWithFormat:@"{\"type\": \"Point\",\"coordinates\":[%f,%f]}",lon,lat];
}

+ (void)deleteAllOrder
{
    RLMResults *rs = [OOrderAvailable allObjects];
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (OOrderAvailable *o in rs) {
        [realm beginWriteTransaction];
        [realm deleteObject:o];
        [realm commitWriteTransaction];
    }
    RELOAD_MENU_LEFT
}

+ (void)saveOrder:(OOrderAvailable*)order
{
    [self deleteAllOrder];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [OOrderAvailable createOrUpdateInDefaultRealmWithValue:order];
    [realm commitWriteTransaction];
}

+ (OOrderAvailable*)getCurrentOrder
{
    RLMResults *rs = [OOrderAvailable allObjects];
    if (rs.count>0) {
        return rs[0];
    }else{
        return nil;
    }
}

+ (OOrderAvailable*)convertToObject:(NSDictionary*)json
{
    OOrderAvailable *order = [[OOrderAvailable alloc]init];
    
    order.oid = [json stringForKey:@"id"];
    order.size = [json stringForKey:@"size"];
    order.price = [json stringForKey:@"courier_reward"];
    order.created = [NSDate convertISO8601ToDate:[json stringForKey:@"created"]];
    
    NSArray *arrPickup = [json arrayForKeyPath:@"pickup_position.coordinates"];
    if (arrPickup.count>0)
    {
        order.pickUpLat = [arrPickup[1] floatValue];
        order.pickUpLon = [arrPickup[0] floatValue];
    }
    
    NSArray *arrDropoff = [json arrayForKeyPath:@"destination_position.coordinates"];
    if (arrDropoff.count>0)
    {
        order.dropOffLat = [arrDropoff[1] floatValue];
        order.dropOffLon = [arrDropoff[0] floatValue];
    }
    
    order.pickupAddress = [json stringForKey:@"pickup_address"];
    order.pickupAddressDetail = [json stringForKey:@"pickup_address_detail"];
    order.dropoffAddress = [json stringForKey:@"destination_address"];
    order.dropoffAddressDetail = [json stringForKey:@"destination_address_detail"];
    order.estimatedPickup = [json stringForKey:@"estimated_pickup_interval"];
    order.estimatedDropoff = [json stringForKey:@"estimated_delivery_interval"];
    order.distance = [json stringForKey:@"distance"];
    order.receiverName = [json stringForKey:@"receiver_name"];
    order.senderName = [json stringForKey:@"sender_name"];
    order.quoteDistance = [json stringForKey:@"quote_distance"];
    order.isReturnTrip = [json boolForKey:@"is_return_trip"];
    
    //additional info for current order active
    NSDictionary *sender = [json dicForKey:@"sender"];
    if (sender){
        order.senderFirstName = [sender stringForKey:@"first_name"];
        order.senderLastName = [sender stringForKey:@"last_name"];
        order.senderPhoto = [sender stringForKey:@"photo"];
        order.senderPhone = [sender stringForKey:@"phone"];
    }

    order.state = [json stringForKey:@"state"];
    order.note = [json stringForKey:@"note"];
    order.phonePickup = [json stringForKey:@"pickup_phone"];
    order.phoneDropoff = [json stringForKey:@"destination_phone"];
    order.stateChange = [NSDate convertISO8601ToDate:[json stringForKey:@"state_changed"]];
    order.timeStart = [NSDate convertISO8601ToDate:[json stringForKey:@"timer_started"]];
    order.timeFinish = [NSDate convertISO8601ToDate:[json stringForKey:@"timer_finished"]];
    order.returnDropoff = [json stringForKey:@"return_destination"];
    
    order.pickupConfirmCode = [json stringForKey:@"pickup_confirmation_code"];
    order.dropoffConfirmCode = [json stringForKey:@"delivery_confirmation_code"];
    order.resolutionNote = [json stringForKey:@"resolution_note"];
    return order;
}

@end
