//
//  VCSignUp.m
//  Delivery
//
//  Created by Long Nguyen on 12/23/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "VCSignUp.h"
#import "VCVerifyPhone.h"

@interface VCSignUp ()<UITextFieldDelegate>{
    UITextField *tfFocus;
}

@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;

@property (weak, nonatomic) IBOutlet UIScrollView *scView;


@end

@implementation VCSignUp

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Registration";
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.tfPhone.inputAccessoryView = [self createToolbarCancelForKeyBoard];
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

- (BOOL)validate{
    if (self.tfFirstName.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter your first name" handler:nil];
        return NO;
    }
    if (self.tfLastName.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter your last name" handler:nil];
        return NO;
    }
    if (self.tfPhone.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter your phone number" handler:nil];
        return NO;
    }
    if (![Util checkPhoneNumber:self.tfPhone.text]) {
        [UIAlertView showErrorWithMessage:@"Invalid phone number" handler:nil];
        return NO;
    }
    if (self.tfEmail.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter your email" handler:nil];
        return NO;
    }
    if (![self.tfEmail.text isEmailValid]) {
        [UIAlertView showErrorWithMessage:@"Invalid email" handler:nil];
        return NO;
    }
    if (self.tfPassword.text.length<6) {
        [UIAlertView showErrorWithMessage:@"Password must be at least 6 characters" handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS
- (IBAction)selectedSubmitButton:(id)sender
{
    //submit to switch to verify phone number screen
    if ([self validate])
    {
        [HServiceAPI registerWithFirstName:self.tfFirstName.text last:self.tfLastName.text phone:[NSString stringWithFormat:@"%@%@",defaultPhonePrefix,self.tfPhone.text] pass:self.tfPassword.text email:self.tfEmail.text success:^{
            
            [HServiceAPI onRequestConfirmCode:self.tfPhone.text success:^(BOOL success)
            {
                if (success)
                {
                    VCVerifyPhone *verify = VCUSER(VCVerifyPhone);
                    verify.strPhone = [NSString stringWithFormat:@"%@%@",defaultPhonePrefix,self.tfPhone.text];
                    [self.navigationController pushViewController:verify animated:YES];
                }
                else
                {
                    DLog(@"failed request confirm code");
                }
            }];
        }
         failed:^{
             DLog(@"failed register");
         }];
    }
}

#pragma mark - DELEGATES


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (tfFocus!=nil) {
        if (textField==self.tfFirstName){
            [self.scView setContentOffset:CGPointMake(0, 228) animated:YES];
        }else if (textField==self.tfLastName){
            [self.scView setContentOffset:CGPointMake(0, 228) animated:YES];
        }else if (textField==self.tfPhone){
            [self.scView setContentOffset:CGPointMake(0, 228) animated:YES];
        }else if (textField==self.tfEmail){
            [self.scView setContentOffset:CGPointMake(0, 228) animated:YES];
        }else if (textField==self.tfPassword){
            [self.scView setContentOffset:CGPointMake(0, 228) animated:YES];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (tfFocus==nil) {
        [self.scView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    tfFocus = textField;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField==tfFocus) {
        tfFocus = nil;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

@end
