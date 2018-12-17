//
//  CustomPageControl.m
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* dotView = [self.subviews objectAtIndex:i];
        UIImageView* dot = nil;
        
        for (UIView* subview in dotView.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView*)subview;
                break;
            }
        }
        
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage)
        {
            dot.frame = CGRectMake(0, -2, 10, 10);
            dot.image = [UIImage imageNamed:@"dot_active"];
        }
        else
        {
            dot.frame = CGRectMake(0, 0, 5, 5);
            dot.image = [UIImage imageNamed:@"dot_inactive"];
        }
    }
}


@end
