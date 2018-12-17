//
//  VCLogin.m
//  Delivery
//
//  Created by Long Nguyen on 12/23/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "VCLogin.h"
#import "VCSignUp.h"
#import "VCForgotPassword.h"
#import "VCVerifyPhone.h"
#import "VCOrderAssign.h"
#import "VCPermission.h"

@interface VCLogin ()<UITextFieldDelegate>{
    UITextField *tfFocus;
}

@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UIScrollView *scView;


@end

@implementation VCLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self setLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = NO;
#ifdef STAGGING
    self.title = @"Beta Zap Courier";
#else
    self.title = @"Zap Courier";
#endif
}

#pragma mark - LAYOUT

- (void)setLayout
{
    self.tfPhone.inputAccessoryView = [self createToolbarCancelForKeyBoard];
}

#pragma mark - FUNCTIONS

- (BOOL)validateLogin{
    if (self.tfPassword.text.length<6) {
        [UIAlertView showErrorWithMessage:@"The password must be at least 6 characters" handler:nil];
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
    if (APPSHARE.arrUserLocation.count<1) {
        [UIAlertView showErrorWithMessage:@"Can't get your location. Please check your device settings." handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS

- (IBAction)selectedLoginButton:(id)sender
{
    RESIGN_KEYBOARD
    if ([self validateLogin])
    {
        //login
        [[Util sharedUtil] showLoading];
        [HServiceAPI loginWithPhone:self.tfPhone.text pass:self.tfPassword.text success:^{
            APPSHARE.userLogin = [OUserLogin getUserLogin];
            RELOAD_MENU_LEFT
            [self updateLocation:APPSHARE.arrUserLocation];
        } failed:^(NSError *error) {
            //teo
        }];
    }
}

- (IBAction)selectedSignUpButton:(id)sender {
    VCSignUp *signup = VCUSER(VCSignUp);
    [self.navigationController pushViewController:signup animated:YES];
}

- (IBAction)selectedForgotButton:(id)sender {
    VCForgotPassword *forgotPass = VCUSER(VCForgotPassword);
    [self.navigationController pushViewController:forgotPass animated:YES];
}

- (IBAction)selectedSkipButton:(id)sender
{
    [APPSHARE addLeftPanelwithOrder:nil];
}

#pragma mark - DELEGATES

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (tfFocus!=nil) {
        [self.scView setContentOffset:CGPointMake(0, 120) animated:YES];
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
    [textField resignFirstResponder];
    if (textField==self.tfPhone) {
        [self.tfPassword becomeFirstResponder];
    }
    return YES;
}

- (void)updateLocation:(NSMutableArray *)data
{
    
    [HServiceAPI updateCurrentPosition:data success:^{
        
        
        if (APPSHARE.userLogin.isPhoneConfirmed)
        {
            if (APPSHARE.userLogin.is_approved)
            {
                if (![APPSHARE.userLogin.proBasket isEqualToString:@""])
                {
                    [HServiceAPI getCurrentActiveBulkOrder:^(NSDictionary *results, NSError *error) {
                        if (!error)
                        {
                            [APPSHARE checkActiveOrder:YES];
                            OBulk *o = [OBulk convertToObject:results];
                            [OBulk saveOrder:o];
                            [APPSHARE addLeftPanelwithBulkOrder:o];
                        }
                        else
                        {
                            [APPSHARE addLeftPanelwithOrder:nil];
                        }
                    }];
                }
                else if (APPSHARE.userLogin.proOrder)
                {
                    [HServiceAPI getCurrentActiveOrder:^(NSArray *results, NSError *error)
                     {
                         if (!error)
                         {
                             OOrderAvailable *o = results[0];
                             [OOrderAvailable saveOrder:o];
                             [APPSHARE addLeftPanelwithOrder:o];
                         }
                         else
                         {
                             [APPSHARE addLeftPanelwithOrder:nil];
                         }
                     }];
                }
                else
                {
                    [[Util sharedUtil] hideLoading];
                    [APPSHARE addLeftPanelwithOrder:nil];
                }
            }
            else
            {
                [[Util sharedUtil] hideLoading];
                [APPSHARE addLeftPanelwithOrder:nil];
            }
        }
        else
        {
            [HServiceAPI verifyPhoneNumber:[NSString stringWithFormat:@"%@%@",defaultPhonePrefix,self.tfPhone.text] success:^(BOOL success) {
                if (success) {
                    VCVerifyPhone *verify = VCUSER(VCVerifyPhone);
                    verify.strPhone = APPSHARE.userLogin.phone;
                    [self.navigationController pushViewController:verify animated:YES];
                }
            }];
        }
    }];
}

@end
