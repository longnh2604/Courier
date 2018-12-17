//
//  LabelColor.m
//  Delivery
//
//  Created by Long Nguyen on 12/30/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "LabelColor.h"

@implementation LabelColor

//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    self.text = @"Do note that Courier is only allowed to wait  10+5 minutes at the Drop-off address, else he/she is able to cancel the delivery with full amount charged";
//    self.textColor = UIColorFromRGB(0x787676);
//}

- (void)setAttrString:(NSString*)string{
    self.text = @"Do note that Courier is only allowed to wait 10+5 minutes at the Drop-off address, else he/she is able to cancel the delivery with full amount charged";
    UIColor *color = UIColorFromRGB(clBlue);
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    self.attributedText = attrStr;
    self.textAlignment = NSTextAlignmentJustified;
}
-(void)setText:(NSString*)text withhighLight:(NSString*)highLight{
    self.text = text;
    self.textColor = UIColorFromRGB(0x787676);
    
    NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    [coloredText addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x0098fc) range:[self.text rangeOfString:highLight]];
    self.attributedText = coloredText;
}

-(void)setText:(NSString*)text withbold:(NSString*)boldString{
    self.text = text;
    self.textColor = UIColorFromRGB(clGray4);
    
    NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:self.text];
    [coloredText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]} range:[self.text rangeOfString:boldString]];
    self.attributedText = coloredText;
}


@end
