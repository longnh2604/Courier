//
//  OBulk.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/26/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBulk : RLMObject

@property NSString *bid;
@property NSString *note;
@property NSString *pickUpAddress;
@property NSString *pickUpPhone;
@property CGFloat   pickUpLat;
@property CGFloat   pickUpLon;
@property NSString *senderAvatar;
@property NSString *senderName;
@property NSString *size;
@property NSString *price;
@property NSString *state;
@property NSDate *created;
@property NSString *distance;

@property RLMArray<OOrderAvailable *><OOrderAvailable> *arOrders;

+ (void)saveOrder:(OBulk*)order;
+ (OBulk*)convertToObject:(NSDictionary*)json;
+ (OBulk*)getCurrentOrder;
+ (void)deleteAllOrder;

@end
