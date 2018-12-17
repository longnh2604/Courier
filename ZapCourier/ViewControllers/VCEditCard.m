//
//  VCEditCard.m
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCEditCard.h"
#import "DefaultButton.h"

@interface VCEditCard ()<UITextFieldDelegate>{
    OPayment *payment;
}


@property (weak, nonatomic) IBOutlet UITextField *tfCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfMonth;
@property (weak, nonatomic) IBOutlet UITextField *tfyear;
@property (weak, nonatomic) IBOutlet UITextField *tfCVV;

@property (weak, nonatomic) IBOutlet DefaultButton *btnSave;



@end

@implementation VCEditCard

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    payment = APPSHARE.userLogin.arPayment[self.cardIdx];
    [self setLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.isFromPresent) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(selectedSkipButton:)];
        self.navigationItem.leftBarButtonItem = item;
    }
    
    self.title = @"Edit card";
}

#pragma mark - LAYOUT

- (void)setLayout{
    self.tfCardNumber.text = payment.maskedNumber;
//    self.tfCVV.text = self.payment.last4;
    self.tfMonth.text = payment.expirationMonth;
    self.tfyear.text = payment.expirationYear;
}

#pragma mark - FUNCTIONS

- (BOOL)validateCard{
    RESIGN_KEYBOARD
    if (self.tfMonth.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter expiration month" handler:nil];
        return NO;
    }
    if (![Util checkNumbericWithString:self.tfMonth.text] || self.tfMonth.text.length>2) {
        [UIAlertView showErrorWithMessage:@"Expiration month invalid" handler:nil];
        return NO;
    }
    if (self.tfMonth.text.intValue<1 || self.tfMonth.text.intValue>12) {
        [UIAlertView showErrorWithMessage:@"Expiration month must be from 1 to 12" handler:nil];
        return NO;
    }
    if (self.tfyear.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter expiration year" handler:nil];
        return NO;
    }
    if (![Util checkNumbericWithString:self.tfyear.text]) {
        [UIAlertView showErrorWithMessage:@"Expiration year invalid" handler:nil];
        return NO;
    }
    if (self.tfyear.text.length>2) {
        [UIAlertView showErrorWithMessage:@"Expiration year must be 2 characters" handler:nil];
        return NO;
    }
    if (self.tfCVV.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter CVC/CVV" handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS

- (void)selectedSkipButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectedSaveButton:(id)sender {
    if ([self validateCard]) {
        if (self.tfMonth.text.length==1) {
            self.tfMonth.text = [NSString stringWithFormat:@"0%@",self.tfMonth.text];
        }
        [HServiceAPI updateCardWithToken:payment.token
                                   month:self.tfMonth.text
                                    year:[NSString stringWithFormat:@"20%@",self.tfyear.text]
                                     cvv:self.tfCVV.text
                                 handler:^(NSDictionary *result, NSError *error) {
                                     if (result!=nil) {
                                         RLMRealm *realm = [RLMRealm defaultRealm];
                                         [realm beginWriteTransaction];
                                         payment = [OPayment convertObject:result];
                                         [realm commitWriteTransaction];
                                         if (self.isFromPresent){
                                             [self.delegate editCardDone:payment];
                                             [self dismissViewControllerAnimated:YES completion:nil];
                                         }else{
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }
                                     }
                                 }];
    }
}
#pragma mark - DELEGATES

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField==self.tfMonth || textField==self.tfyear) {
        if (strFinal.length>2) {
            return NO;
        }
    }
    return YES;
}

@end
