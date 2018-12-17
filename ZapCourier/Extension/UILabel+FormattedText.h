//
//  UILabel+FormattedText.h
//  VoteNail
//
//  Created by Long Nguyen on 3/24/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FormattedText)

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;

- (void)setTextColor:(UIColor *)textColor afterOccurenceOfString:(NSString*)separator;
- (void)setFont:(UIFont *)font afterOccurenceOfString:(NSString*)separator;

@end
