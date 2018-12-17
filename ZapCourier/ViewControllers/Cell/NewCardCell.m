//
//  NewCardCell.m
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "NewCardCell.h"

@implementation NewCardCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLayoutWithIdx:(NSIndexPath*)idx number:(NSString*)number{
    self.idx = idx;
    
    if (idx.row==0) {
        //card number
        self.tfInfo.placeholder = @"Card number";
        self.tfInfo.keyboardType = UIKeyboardTypePhonePad;
        self.tfInfo.text = number;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.delegate endEditingInfoWithIndex:self.idx string:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.idx.row==0){
        if (strFinal.length>maxCardNumberLength) {
            return NO;
        }
    }
    return YES;
}


@end
