//
//  OUserLogin.h
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUserLogin : RLMObject

@property NSInteger tmpID; //for local
@property NSString *uid; //user id from server
@property NSString *email;
@property NSString *firstName;
@property NSString *lastName;
@property BOOL isEmailConfirmed;
@property BOOL isPhoneConfirmed;
@property NSString *phone;
@property NSString *photo;
@property NSString *address;
@property NSString *passport;
@property NSString *driversLicense;
@property NSString *vehiclePlate;
@property BOOL is_approved;
@property NSString *filledPersonalData;
@property BOOL activeOrder;
@property NSString *poAvailable;
@property NSString *poPending;
@property NSString *poHold;
@property NSString *poPaid;

@property BOOL is_bulk;
@property NSString *proBasket;
@property NSString *proOrder;

@property NSString *locationUser;
@property NSString *locationCourse;
@property NSString *locationAltitude;
@property NSString *locationAccuracy;
@property NSString *locationSpeed;

@property RLMArray<OPayment *><OPayment> *arPayment;

+ (void)saveUserWithObject:(NSDictionary*)object;
+ (OUserLogin*)getUserLogin;
+ (void)deleteAllObjects;
+ (void)confirmedPhone;
+ (void)saveObject:(OUserLogin*)user;
+ (void)saveUserLocation:(NSDictionary*)object;
+ (void)updateBulkOrder:(NSString *)bid;

@end
