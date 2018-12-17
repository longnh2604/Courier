//
//  VCPersonalDetail.m
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCPersonalDetail.h"
#import "VCLogin.h"
#import "DefaultButton.h"

@interface VCPersonalDetail ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfPassport;
@property (weak, nonatomic) IBOutlet UITextField *tfAdd;
@property (weak, nonatomic) IBOutlet UITextField *tfDriver;
@property (weak, nonatomic) IBOutlet UITextField *tfPlateNo;

@property (weak, nonatomic) IBOutlet DefaultButton *btnContinue;

@end

@implementation VCPersonalDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    APPSHARE.userLogin = [OUserLogin getUserLogin];
    [self.btnContinue addTarget:self action:@selector(onClickContinue) forControlEvents:UIControlEventTouchUpInside];
    self.title = @"Personal Details";
}

- (void)selectedBackButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickContinue
{
    if (self.tfAdd.text.length!=0 || self.tfDriver.text.length!=0 || self.tfPlateNo.text.length!=0 || self.tfPassport.text.length!=0) {
        [HServiceAPI updateAccountwithfirstname:APPSHARE.userLogin.firstName lastname:APPSHARE.userLogin.lastName address:self.tfAdd.text passport:self.tfPassport.text driver:self.tfDriver.text vehicle:self.tfPlateNo.text handler:^(NSDictionary *result, NSError *error)
         {
             if (!error)
             {
                 [APPSHARE addLeftPanelwithOrder:nil];
             }
         }];
    }else{
        [APPSHARE addLeftPanelwithOrder:nil];
    }
}

#pragma Textfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.tfPassport == textField) {
        [self.tfAdd becomeFirstResponder];
    }else if (self.tfAdd == textField){
        [self.tfDriver becomeFirstResponder];
    }else if (self.tfDriver == textField){
        [self.tfPlateNo becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}


@end
