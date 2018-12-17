//
//  UILabel+FormattedText.m
//  VoteNail
//
//  Created by Long Nguyen on 3/24/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import "UILabel+FormattedText.h"

@implementation UILabel (FormattedText)

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	[text addAttribute:NSForegroundColorAttributeName
	             value:textColor
	             range:range];

	[self setAttributedText:text];
}

- (void)setFont:(UIFont *)font range:(NSRange)range {
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	[text addAttribute:NSFontAttributeName
	             value:font
	             range:range];

	[self setAttributedText:text];
}

- (void)setTextColor:(UIColor *)textColor afterOccurenceOfString:(NSString *)separator {
	NSRange range = [self.text rangeOfString:separator];

	if (range.location != NSNotFound) {
		range.location++;
		range.length = self.text.length - range.location;
		[self setTextColor:textColor range:range];
	}
}

- (void)setFont:(UIFont *)font afterOccurenceOfString:(NSString *)separator {
	NSRange range = [self.text rangeOfString:separator];

	if (range.location != NSNotFound) {
		range.location++;
		range.length = self.text.length - range.location;
		[self setFont:font range:range];
	}
}

@end
