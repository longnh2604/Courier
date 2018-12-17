//
//  UIImage+Extension.m
//  Property
//
//  Created by xxx on 6/4/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extensions)

//convert image
-(UIImage*)convertImageToWidth:(CGFloat)w{
    float ratioW = w/self.size.width;
    return [self convertToSize:CGSizeMake(self.size.width*ratioW, self.size.height*ratioW)];
}
//resize image
- (UIImage *)convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


- (UIImage*)setIconForCard:(NSString*)type{
    NSString *imgName;
    if ([type.lowercaseString isEqualToString:@"mastercard"]) {
        imgName = @"MasterCard";
    }else if ([type.lowercaseString isEqualToString:@"american express"]) {
        imgName = @"Amex";
    }else if ([type.lowercaseString isEqualToString:@"visa"]) {
        imgName = @"Visa";
    }else{
        imgName = @"UnknownCard";
    }
    
    return [UIImage imageNamed:imgName];
}

@end
