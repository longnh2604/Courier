//
//  UITextField+FormattedText.m
//  VoteNail
//
//  Created by Long Nguyen on 3/24/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import "UITextField+FormattedText.h"

@implementation UITextField (FormattedText)

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.attributedText];
    [text addAttribute: NSForegroundColorAttributeName
                 value: textColor
                 range: range];

    [self setAttributedText: text];
}

- (void)setPlaceholderColor:(UIColor *)textColor range:(NSRange)range {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.attributedPlaceholder];
    [text addAttribute: NSForegroundColorAttributeName
                 value: textColor
                 range: range];
    
    [self setAttributedPlaceholder:text];
}

@end
