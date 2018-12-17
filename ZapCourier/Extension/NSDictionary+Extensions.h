//
//  NSDictionary+Extensions.h
//  TNP
//
//  Created by Long Nguyen on 4/13/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extensions)

- (NSString *) stringForKey:(NSString *)key;
- (NSString *)stringForKeyPath:(NSString *)key;
- (NSDictionary *)dicForKey:(NSString *)key;
- (NSArray*) arrayForKey:(NSString *)key;
- (NSArray *)arrayForKeyPath:(NSString *)key;
- (NSInteger) intForKey:(NSString *)key;
- (BOOL) boolForKey:(NSString *)key;
- (NSDate *) dateForKey:(NSString *)key;
- (NSDate *)dateRubyForKey:(NSString *)key;

@end
