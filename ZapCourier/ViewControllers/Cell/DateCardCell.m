//
//  DateCardCell.m
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "DateCardCell.h"

@implementation DateCardCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configCell:(NSString*)month year:(NSString*)year cvv:(NSString*)cvv{
    self.tfMonth.text = month;
    self.tfYear.text = year;
    self.tfCVV.text = cvv;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.delegate endEditingDateCardDelegate:self.tfMonth.text year:self.tfYear.text cvv:self.tfCVV.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField!=self.tfCVV) {
        if (strFinal.length>2) {
            return NO;
        }
    }else{
        if (strFinal.length>4) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (self.tfMonth==textField) {
        [self.tfYear becomeFirstResponder];
    }else if (textField==self.tfYear){
        [self.tfCVV becomeFirstResponder];
    }
    return YES;
}

@end
