//
//  LocationManager.h
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *coreLocationLocationManager;
@property (nonatomic, strong) CLLocation *lastLocation;

+ (LocationManager *)shared;
- (void)startUpdating;

@end
