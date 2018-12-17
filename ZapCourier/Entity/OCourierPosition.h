//
//  OCourierPosition.h
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCourierPosition : NSObject

@property (nonatomic) NSDate *timestamp;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic) double course;
@property (nonatomic) double speed;


+(OCourierPosition*)positionMap:(NSDictionary*)dic;

@end
