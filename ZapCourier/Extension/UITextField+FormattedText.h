//
//  UITextField+FormattedText.h
//  VoteNail
//
//  Created by Long Nguyen on 3/24/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (FormattedText)

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setPlaceholderColor:(UIColor *)textColor range:(NSRange)range;

@end
