//
//  NSTimer+Utils.h
//  Modal
//
//  Created by Long Nguyen on 7/15/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VoidBlock)(void);

@interface NSTimer (Utils)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(VoidBlock)block;
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(VoidBlock)block;
- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(VoidBlock)block;

@end

@interface VoidBlockWrapper : NSObject

@property (nonatomic, copy) VoidBlock block;
@property (nonatomic, retain) id userInfo;

- (id)initWithBlock:(VoidBlock)aBlock userInfo:(id)someUserInfo;
- (void)performBlock;

@end
