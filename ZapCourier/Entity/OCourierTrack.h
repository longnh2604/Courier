//
//  OCourierTrack.h
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCourierPosition.h"

@interface OCourierTrack : NSObject

@property (nonatomic) int cid;
@property (nonatomic) NSMutableArray *tail;
@property (nonatomic) GMSMarker *pin;

+(OCourierTrack*)trackMap:(NSDictionary*)dic;


@end
