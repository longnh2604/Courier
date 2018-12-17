//
//  OCourierTrack.m
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "OCourierTrack.h"

@implementation OCourierTrack


+(OCourierTrack*)trackMap:(NSDictionary*)dic{
    OCourierTrack *track = [[OCourierTrack alloc]init];
    
    track.cid = (int)[dic intForKey:@"id"];
    
    NSArray *artail = [dic arrayForKey:@"track_tail"];
    track.tail = [NSMutableArray array];
    if (artail.count>0) {
        for (NSDictionary *dicTail in artail) {
            OCourierPosition *p = [OCourierPosition positionMap:dicTail];
            [track.tail addObject:p];
        }
    }
    
    return track;
}

@end
