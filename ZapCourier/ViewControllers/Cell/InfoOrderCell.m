//
//  InfoOrderCell.m
//  Delivery
//
//  Created by Long Nguyen on 12/30/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "InfoOrderCell.h"

@implementation InfoOrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(BOOL)phone forName:(NSString*)strName forPhone:(NSString*)strPhone sender:(BOOL)sender index:(NSIndexPath*)idx{
    self.isSender = sender;
    self.isPhone = phone;
    self.imvIcon.image = (phone)?[UIImage imageNamed:@"icon_phone"]:[UIImage imageNamed:@"icon_name"];
    if (phone){
        self.tfInfo.placeholder = @"Phone number";
        self.tfInfo.keyboardType = UIKeyboardTypePhonePad;
    }else{
        self.tfInfo.placeholder = (sender)?@"Sender's name":@"Receiver's name";
        self.tfInfo.keyboardType = UIKeyboardTypeDefault;
    }
    [self.btnCountryCode setTitleColor:(sender)?UIColorFromRGB(0x67809f):UIColorFromRGB(0xe91e63) forState:UIControlStateNormal];
    self.btnCountryCode.hidden = (phone)?NO:YES;
    self.widthBtnCountryCode.constant = 64;
    if (!phone){
        self.tfInfo.text = strName;
    }else{
        self.tfInfo.text = [strPhone stringByReplacingOccurrencesOfString:defaultPhonePrefix withString:@""];
    }
    self.idx = idx;
}

- (void)setInfoNote:(NSString*)note index:(NSIndexPath*)idx{
    self.imvIcon.image = [UIImage imageNamed:@"icon_note"];
    self.tfInfo.placeholder = @"Optional info about your package";
    self.btnCountryCode.hidden = YES;
    self.widthBtnCountryCode.constant = 32;
    self.tfInfo.keyboardType = UIKeyboardTypeDefault;
    
    if (note.length>0) self.tfInfo.text = note;
    self.isNote = YES;
    self.idx = idx;
}

- (void)validate{
    if (self.isNote) {
        //note
    }else{
        //
        if (self.isSender) {
            //sender
            if (self.isPhone) {
                //phone
            }else{
                //name
            }
        }else{
            //receiver
            if (self.isPhone) {
                //phone
            }else{
                //name
            }
        }
    }
}

//MARK: - Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.delegate beginEditingWithIndex:self.idx];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.delegate updateInfoOrderWithInfo:textField.text index:self.idx];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.isPhone) {
        textField.keyboardType = UIKeyboardTypePhonePad;
    }else{
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (strFinal.length>phoneLength && self.isPhone) {
        return NO;
    }
    return YES;
}

@end
