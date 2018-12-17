//
//  NSString+Utils.h
//  Slide App
//
//  Created by Long Nguyen on 5/19/14.
//  Copyright (c) 2014 Chung Nguyen Van. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (CGFloat)heightWithFont:(UIFont*) font;
- (CGFloat)heightWithFont:(UIFont*)font forWidth:(CGFloat)width;
- (CGSize)textSizeWithFont:(UIFont *)font fieldSize:(CGSize)size;

- (NSString *)stringify;
+ (NSString *)genRandStringLength:(int)len;
- (NSString *)stringByStrippingHTML;
- (NSString *)stringByRemovingSuffix:(NSString *)suffix;
- (NSString*)stringRemoveSpace;
- (NSString *)trimWhiteSpace;
+ (BOOL)isInlucdedChar:(NSString *)c atTheFirst:(NSString *)string;

- (BOOL)containsString:(NSString *)substring;
- (BOOL)containsString:(NSString *)substring caseSensitive:(BOOL)sensitive;

- (BOOL)isNSNull;
- (BOOL)matches:(NSString *)pattern;
- (BOOL)isEmailValid;
- (BOOL)isPhoneNumber;
- (NSString*)formatNumber;

@end


@interface NSString (HTML)

- (NSString *)decodeHTMLCharacterEntities;
- (NSString *)encodeHTMLCharacterEntities;
- (NSString *)addUrlParam:(NSString *)param withValue:(NSString *)value;
- (NSString *)urlEncoded;
-(NSString *)urlEncode;

@end
