//
//  OUserLogin.m
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OUserLogin.h"

@implementation OUserLogin


+ (NSString *)primaryKey {
    return @"tmpID";
}


+ (void)saveUserWithObject:(NSDictionary*)object
{
    OUserLogin *user = [[OUserLogin alloc]init];
    
    user.tmpID = 1;//default
    user.email = [object stringForKey:@"email"];
    user.firstName = [object stringForKey:@"first_name"];
    user.lastName = [object stringForKey:@"last_name"];
    user.uid = [object stringForKey:@"id"];
    user.phone = [object stringForKey:@"phone"];
    user.photo = [object stringForKey:@"photo"];
    user.isEmailConfirmed = [object boolForKey:@"is_email_confirmed"];
    user.isPhoneConfirmed = [object boolForKey:@"is_phone_confirmed"];
    
    //new
    user.address = [object stringForKey:@"address"];
    user.passport = [object stringForKey:@"passport"];
    user.driversLicense = [object stringForKey:@"drivers_license"];
    user.vehiclePlate = [object stringForKey:@"vehicle_plate"];
    user.is_approved = [object boolForKey:@"is_approved"];
    user.filledPersonalData = [object stringForKey:@"filled_personal_data"];
    user.activeOrder = [object boolForKey:@"has_active_order"];
    
    user.is_bulk = [object boolForKey:@"can_bulkorder"];
    user.proBasket = [object stringForKey:@"processing_basket"];
    user.proOrder = [object stringForKey:@"processing_order"];
    
    //payout
    NSDictionary *arPayout = [object objectForKey:@"payout_totals"];
    user.poAvailable = [arPayout objectForKey:@"available"];
    user.poPending = [arPayout objectForKey:@"pending"];
    user.poHold = [arPayout objectForKey:@"hold"];
    user.poPaid = [arPayout objectForKey:@"paid"];
    
    //payment
    NSArray *arPay = [object arrayForKey:@"payment_methods"];
    for (NSDictionary *payment in arPay) {
        OPayment *p = [OPayment convertObject:payment];
        [user.arPayment addObject:p];
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [OUserLogin createOrUpdateInDefaultRealmWithValue:user];
    [realm commitWriteTransaction];
}

+ (void)saveObject:(OUserLogin*)user
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [OUserLogin createOrUpdateInDefaultRealmWithValue:user];
    [realm commitWriteTransaction];
}

+ (void)confirmedPhone
{
    OUserLogin *login = [self getUserLogin];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    login.isPhoneConfirmed = YES;
    [OUserLogin createOrUpdateInDefaultRealmWithValue:login];
    [realm commitWriteTransaction];
}

+ (OUserLogin*)getUserLogin{
    RLMResults *rs = [OUserLogin objectsWhere:@"tmpID == 1"];
    if (rs.count>0) {
        return rs[0];
    }else{
        return nil;
    }
}

+ (void)deleteAllObjects{
    RLMResults *rs = [OUserLogin allObjects];
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for (OUserLogin *u in rs) {
        [realm beginWriteTransaction];
        [realm deleteObject:u];
        [realm commitWriteTransaction];
    }
}

+ (void)saveUserLocation:(NSDictionary*)object
{
    OUserLogin *login = [self getUserLogin];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [OUserLogin createOrUpdateInDefaultRealmWithValue:login];
    [realm commitWriteTransaction];
}

+ (void)updateBulkOrder:(NSString *)bid
{
    OUserLogin *login = [self getUserLogin];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    login.proBasket = bid;
    [OUserLogin createOrUpdateInDefaultRealmWithValue:login];
    [realm commitWriteTransaction];
}

@end
