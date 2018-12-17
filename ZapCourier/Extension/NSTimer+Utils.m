//
//  NSTimer+Utils.m
//  Modal
//
//  Created by Long Nguyen on 7/15/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#import "NSTimer+Utils.h"

@implementation NSTimer (Utils)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(VoidBlock)block;
{
    VoidBlockWrapper *wrapper = [[VoidBlockWrapper alloc] initWithBlock:block userInfo:nil];
    NSTimer *timer = [self scheduledTimerWithTimeInterval:seconds target:wrapper selector:@selector(performBlock) userInfo:nil repeats:repeats];
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(VoidBlock)block;
{
    VoidBlockWrapper *wrapper = [[VoidBlockWrapper alloc] initWithBlock:block userInfo:nil];
    NSTimer *timer = [self timerWithTimeInterval:seconds target:wrapper selector:@selector(performBlock) userInfo:nil repeats:repeats];
    return timer;
}

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(VoidBlock)block;
{
    VoidBlockWrapper *wrapper = [[VoidBlockWrapper alloc] initWithBlock:block userInfo:nil];
    NSTimer *timer = [self initWithFireDate:date interval:seconds target:wrapper selector:@selector(performBlock) userInfo:nil repeats:repeats];
    return timer;
}

@end

@implementation VoidBlockWrapper

@synthesize block;
@synthesize userInfo;

#pragma mark Initialization

- (id)initWithBlock:(VoidBlock)aBlock userInfo:(id)someUserInfo;
{
    if (!(self = [super init])) {
        return nil;
    }
    
    block = [aBlock copy];
    
    return self;
}

- (void)dealloc;
{
    block = nil;
    userInfo = nil;
}

#pragma mark Public Methods

- (void)performBlock;
{
    if (self.block) {
        self.block();
    }
}

@end
