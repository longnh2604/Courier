//
//  NSString+Utils.m
//  Slide App
//
//  Created by Long Nguyen on 5/19/14.
//  Copyright (c) 2014 Chung Nguyen Van. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

-(CGFloat)heightWithFont:(UIFont*) font {
    NSDictionary *attrDict = @{NSFontAttributeName : font};
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
    return rect.size.height;
}

-(CGFloat)heightWithFont:(UIFont*)font forWidth:(CGFloat)width{
    
    NSDictionary *attrDict = @{NSFontAttributeName : font};
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil];
    return rect.size.height;
}

- (CGSize)textSizeWithFont:(UIFont *)font fieldSize:(CGSize)size {
    if (self == nil || [self trimWhiteSpace].length == 0) {
        return CGSizeZero;
    }
    
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGSize boundingBox = [self boundingRectWithSize:size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:font}
                                                context:nil].size;
        return CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    }
    else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
    }
}

- (NSString *)stringify {
    NSString *str = (self == nil || self.length == 0 || [self isEqualToString:@"(null)"] || (self == (id)[NSNull null])) ? @"" : self;
    NSString *output = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return output ?: @"";
}

+ (NSString *)genRandStringLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++)
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    
    return randomString;
}



- (NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [[self copy] init];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (NSString *)stringByRemovingSuffix:(NSString *)suffix {
    if (suffix.length > self.length) {
        return nil;
    }
    if (suffix.length == 0) {
        return self;
    }
    NSString *s = [self substringFromIndex:self.length - suffix.length];
    if ([s isEqualToString:suffix]) {
        return [self substringToIndex:self.length - suffix.length];
    } else {
        return nil;
    }
}

- (NSString*)stringRemoveSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)trimWhiteSpace {
    return [[self stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (BOOL)isInlucdedChar:(NSString *)c atTheFirst:(NSString *)string {
    NSString *phoneNumber = [string substringToIndex:1];
    return [phoneNumber isEqualToString:c];
}

- (BOOL)containsString:(NSString *)substring {
    NSRange suffixRange = [self rangeOfString:substring];
    
    if (suffixRange.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (BOOL)containsString:(NSString *)substring caseSensitive:(BOOL)sensitive {
    NSRange suffixRange = [self rangeOfString:substring options:NSCaseInsensitiveSearch];
    if (sensitive == YES) {
        suffixRange = [self rangeOfString:substring];
    }
    
    if (suffixRange.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (BOOL)matches:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if(regex == nil) {
        return NO;
    }
    
    NSUInteger n = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    return n == 1;
}



- (BOOL)isNSNull {
    return [self isKindOfClass:[NSNull class]];
}

- (BOOL)isEmailValid {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isPhoneNumber {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9]{6,14}$"] evaluateWithObject:self];
}



- (NSString*)formatNumber{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setCurrencySymbol:@""];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:self.doubleValue]];
}


@end

@implementation NSString (HTML)

- (NSString *)decodeHTMLCharacterEntities {
    if ([self rangeOfString:@"&"].location == NSNotFound) {
        return self;
    } else {
        NSMutableString *escaped = [NSMutableString stringWithString:self];
        NSArray *codes = [NSArray arrayWithObjects:
                          @"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;", @"&curren;", @"&yen;", @"&brvbar;",
                          @"&sect;", @"&uml;", @"&copy;", @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;",
                          @"&macr;", @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
                          @"&para;", @"&middot;", @"&cedil;", @"&sup1;", @"&ordm;", @"&raquo;", @"&frac14;",
                          @"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;", @"&Acirc;",
                          @"&Atilde;", @"&Auml;", @"&Aring;", @"&AElig;", @"&Ccedil;", @"&Egrave;",
                          @"&Eacute;", @"&Ecirc;", @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;",
                          @"&ETH;", @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;", @"&Ouml;",
                          @"&times;", @"&Oslash;", @"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", @"&Yacute;",
                          @"&THORN;", @"&szlig;", @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
                          @"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;",
                          @"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", @"&eth;", @"&ntilde;", @"&ograve;",
                          @"&oacute;", @"&ocirc;", @"&otilde;", @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
                          @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;", @"&yuml;", nil];
        
        NSUInteger i, count = [codes count];
        
        // Html
        for (i = 0; i < count; i++) {
            NSRange range = [self rangeOfString:[codes objectAtIndex:i]];
            if (range.location != NSNotFound) {
                [escaped replaceOccurrencesOfString:[codes objectAtIndex:i]
                                         withString:[NSString stringWithFormat:@"%C", (unichar)(160 + i)]
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [escaped length])];
            }
        }
        
        // The following five are not in the 160+ range
        
        // @"&amp;"
        NSRange range = [self rangeOfString:@"&amp;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&amp;"
                                     withString:[NSString stringWithFormat:@"%C", 38]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
        
        // @"&lt;"
        range = [self rangeOfString:@"&lt;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&lt;"
                                     withString:[NSString stringWithFormat:@"%C", 60]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
        
        // @"&gt;"
        range = [self rangeOfString:@"&gt;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&gt;"
                                     withString:[NSString stringWithFormat:@"%C", 62]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
        
        // @"&apos;"
        range = [self rangeOfString:@"&apos;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&apos;"
                                     withString:[NSString stringWithFormat:@"%C", 39]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
        
        // @"&quot;"
        range = [self rangeOfString:@"&quot;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&quot;"
                                     withString:[NSString stringWithFormat:@"%C", 34]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }
        
        // Decimal & Hex
        NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
        i = 0;
        
        while (i < [escaped length]) {
            start = [escaped rangeOfString:@"&#"
                                   options:NSCaseInsensitiveSearch
                                     range:searchRange];
            
            finish = [escaped rangeOfString:@";"
                                    options:NSCaseInsensitiveSearch
                                      range:searchRange];
            
            if (start.location != NSNotFound && finish.location != NSNotFound &&
                finish.location > start.location) {
                NSRange entityRange = NSMakeRange(start.location, (finish.location - start.location) + 1);
                NSString *entity = [escaped substringWithRange:entityRange];
                NSString *value = [entity substringWithRange:NSMakeRange(2, [entity length] - 2)];
                
                [escaped deleteCharactersInRange:entityRange];
                
                if ([value hasPrefix:@"x"]) {
                    unsigned tempInt = 0;
                    NSScanner *scanner = [NSScanner scannerWithString:[value substringFromIndex:1]];
                    [scanner scanHexInt:&tempInt];
                    [escaped insertString:[NSString stringWithFormat:@"%C", (unichar)tempInt] atIndex:entityRange.location];
                } else {
                    [escaped insertString:[NSString stringWithFormat:@"%C", (unichar)[value intValue]] atIndex:entityRange.location];
                } i = start.location;
            } else { i++; }
            searchRange = NSMakeRange(i, [escaped length] - i);
        }
        
        return escaped;    // Note this is autoreleased
    }
}

- (NSString *)encodeHTMLCharacterEntities {
    NSMutableString *encoded = [NSMutableString stringWithString:self];
    
    // @"&amp;"
    NSRange range = [self rangeOfString:@"&"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"&"
                                 withString:@"&amp;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
    
    // @"&lt;"
    range = [self rangeOfString:@"<"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"<"
                                 withString:@"&lt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
    
    // @"&gt;"
    range = [self rangeOfString:@">"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@">"
                                 withString:@"&gt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }
    
    return encoded;
}

- (NSString *)addUrlParam:(NSString *)param withValue:(NSString *)value {
    NSString *pathSpecifier = @"?";
    if ([self rangeOfString:@"?" options:(NSCaseInsensitiveSearch)].location != NSNotFound) {
        pathSpecifier = @"&";
    }
    return [self stringByAppendingFormat:@"%@%@=%@",pathSpecifier,param,value];
}

- (NSString *)urlEncoded {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge_retained CFStringRef)self,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",kCFStringEncodingUTF8);
}

-(NSString *)urlEncode{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}



@end
