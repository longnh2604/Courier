//
//  OCourierPosition.m
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "OCourierPosition.h"

@implementation OCourierPosition

+(OCourierPosition*)positionMap:(NSDictionary*)dic{
    OCourierPosition *p = [[OCourierPosition alloc]init];
    
    p.timestamp = [NSDate convertISO8601ToDate:[dic stringForKey:@"timestamp"]];
    
    NSArray *arCoordinates = [dic valueForKeyPath:@"position.coordinates"];
    if (arCoordinates.count==2) {
        p.coordinate = CLLocationCoordinate2DMake([arCoordinates[1] doubleValue], [arCoordinates[0] doubleValue]);
    }
    p.course = [dic intForKey:@"course"];
    p.speed = [dic intForKey:@"speed"];
    
    return p;
}

@end
