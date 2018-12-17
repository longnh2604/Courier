//
//  UIImage+Extension.h
//  Property
//
//  Created by xxx on 6/4/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Extensions)

-(UIImage*)convertImageToWidth:(CGFloat)w;
- (UIImage *)convertToSize:(CGSize)size;
- (UIImage*)setIconForCard:(NSString*)type;

@end
