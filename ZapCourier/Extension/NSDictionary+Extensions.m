//
//  NSDictionary+Extensions.m
//  TNP
//
//  Created by Long Nguyen on 4/13/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#import "NSDictionary+Extensions.h"

@implementation NSDictionary (Extensions)



- (NSString *)stringForKey:(NSString *)key {
    if ([Util isNullOrNilObject:[self objectForKey:key]]) {
        return @"";
    }
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSString class]]) {
            return (NSString *)object;
        }
        if ([object isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)object;
            return [number stringValue];
        }
        if ([object isKindOfClass:[NSDecimalNumber class]]) {
            NSDecimalNumber *number = (NSDecimalNumber *)object;
            return [number stringValue];
        }
    }
    return @"";
}
- (NSString *)stringForKeyPath:(NSString *)key {
    if ([Util isNullOrNilObject:[self valueForKeyPath:key]]) {
        return @"";
    }
    NSObject *object = [self valueForKeyPath:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSString class]]) {
            return (NSString *)object;
        }
        if ([object isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)object;
            return [number stringValue];
        }
        if ([object isKindOfClass:[NSDecimalNumber class]]) {
            NSDecimalNumber *number = (NSDecimalNumber *)object;
            return [number stringValue];
        }
    }
    return @"";
}

- (NSDictionary *)dicForKey:(NSString *)key {
    if ([Util isNullOrNilObject:[self objectForKey:key]]) {
        return nil;
    }
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            return (NSDictionary *)object;
        }
    }
    return nil;
}

- (NSArray *)arrayForKey:(NSString *)key {
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSArray class]]) {
            return (NSArray *)object;
        }
    }
    return nil;
}
- (NSArray *)arrayForKeyPath:(NSString *)key {
    NSObject *object = [self valueForKeyPath:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSArray class]]) {
            return (NSArray *)object;
        }
    }
    return nil;
}

- (NSInteger)intForKey:(NSString *)key {
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSString class]]) {
            return [((NSString *)object) intValue];
        }
        return (NSInteger)object;
    }
    return 0;
}

- (BOOL)boolForKey:(NSString *)key {
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        if ([object isKindOfClass:[NSString class]]) {
            return [((NSString *)object) boolValue];
        }
        if ([object isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)object;
            return [number intValue] == 1;
        }
        return ((NSInteger)object) == 1;
    }
    return NO;
}

- (NSDate *)dateForKey:(NSString *)key {
    if ([Util isNullOrNilObject:[self objectForKey:key]]) {
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *date = [formatter dateFromString:((NSString *)object)];
        return date;
    }
    return [NSDate dateWithTimeIntervalSince1970:0];
}

- (NSDate *)dateRubyForKey:(NSString *)key {
    if ([Util isNullOrNilObject:[self objectForKey:key]]) {
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSObject *object = [self objectForKey:key];
    if (object != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *date = [formatter dateFromString:((NSString *)object)];
        return date;
    }
    return [NSDate dateWithTimeIntervalSince1970:0];
}

@end
