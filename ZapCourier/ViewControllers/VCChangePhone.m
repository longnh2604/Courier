//
//  VCChangePhone.m
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCChangePhone.h"
#import "DefaultButton.h"
#import "VCVerifyPhone.h"

@interface VCChangePhone ()

@property (weak, nonatomic) IBOutlet UIButton *btnPrefixPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet DefaultButton *btnReceiveCode;




@end

@implementation VCChangePhone

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tfPhone.text = [APPSHARE.userLogin.phone stringByReplacingOccurrencesOfString:defaultPhonePrefix withString:@""];
    self.tfPhone.inputAccessoryView = [self createToolbarCancelForKeyBoard];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.title = @"Forgot Password";
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

- (BOOL)validatePhone{
    if (self.tfPhone.text.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter your phone number" handler:nil];
        return NO;
    }
    if (![Util checkPhoneNumber:self.tfPhone.text]) {
        [UIAlertView showErrorWithMessage:@"Invalid phone number" handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS

- (IBAction)selectedReceiveCodeButton:(id)sender {
    if ([self validatePhone]) {
        [HServiceAPI verifyPhoneNumber:self.tfPhone.text success:^(BOOL success) {
            if (success) {
                VCVerifyPhone *verify = VCUSER(VCVerifyPhone);
                verify.strPhone = [NSString stringWithFormat:@"%@%@",defaultPhonePrefix,self.tfPhone.text];
                [self.navigationController pushViewController:verify animated:YES];
            }
        }];
    }
}

- (void)selectedBackButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DELEGATES



@end
