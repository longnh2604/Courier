//
//  LocationManager.m
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

+ (LocationManager *)shared {
    static LocationManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[LocationManager alloc] init];
    });
    
    return _shared;
}

- (void)startUpdating{
    _coreLocationLocationManager.delegate = self;
    _coreLocationLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([_coreLocationLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_coreLocationLocationManager requestWhenInUseAuthorization];
    }
    [_coreLocationLocationManager startUpdatingLocation];
}

- (BOOL)isAuthorized{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    return (status == kCLAuthorizationStatusAuthorizedAlways);
}

//MARK: - Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    _lastLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    DLog(@"get location error = %@",error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([self isAuthorized]) {
        [self startUpdating];
    }
}


@end
