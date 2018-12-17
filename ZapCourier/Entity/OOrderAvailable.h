//
//  OOrderAvailable.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OOrderAvailable : RLMObject

@property NSString      *oid;
@property NSString      *size;
@property NSString      *price;
@property NSDate        *created;
@property CGFloat       pickUpLat;
@property CGFloat       pickUpLon;
@property CGFloat       dropOffLat;
@property CGFloat       dropOffLon;
@property NSString      *pickupAddress;
@property NSString      *pickupAddressDetail;
@property NSString      *dropoffAddress;
@property NSString      *dropoffAddressDetail;
@property NSString      *estimatedPickup;
@property NSString      *estimatedDropoff;
@property NSString      *distance;
@property NSString      *receiverName;
@property NSString      *senderName;
@property NSString      *quoteDistance;
@property BOOL          isReturnTrip;
@property NSString      *senderFirstName;
@property NSString      *senderLastName;
@property NSString      *senderPhone;
@property NSString      *senderPhoto;
@property NSString      *state;
@property NSString      *note;
@property NSString      *phonePickup;
@property NSString      *phoneDropoff;
@property NSDate        *stateChange;
@property NSDate        *timeStart;
@property NSDate        *timeFinish;
@property NSString      *returnDropoff;

@property NSString      *pickupConfirmCode;
@property NSString      *dropoffConfirmCode;
@property NSString      *resolutionNote;

+ (NSString*)convertToGeoJSON:(CGFloat)lat lon:(CGFloat)lon;
+ (void)saveOrder:(OOrderAvailable*)order;
+ (OOrderAvailable*)convertToObject:(NSDictionary*)json;
+ (OOrderAvailable*)getCurrentOrder;
+ (void)deleteAllOrder;

@end
RLM_ARRAY_TYPE(OOrderAvailable)