//
//  DefaultButton.m
//  Delivery
//
//  Created by Long Nguyen on 12/25/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "DefaultButton.h"

@implementation DefaultButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
}

@end
