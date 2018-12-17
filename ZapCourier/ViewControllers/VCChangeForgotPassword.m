//
//  VCChangeForgotPassword.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCChangeForgotPassword.h"
#import "VCLogin.h"

@interface VCChangeForgotPassword ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfNew;

@end

@implementation VCChangeForgotPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Restore password";
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

- (BOOL)validatePassword{
    if (self.tfNew.text.length<6) {
        [UIAlertView showErrorWithMessage:@"Your password must be at least 6 characters" handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS

- (IBAction)selectedChangeButton:(id)sender {
    if ([self validatePassword]) {
        [HServiceAPI changeForgotPassword:self.strPhone code:self.strCode new:self.tfNew.text handler:^(BOOL finish, NSError *error) {
            if (finish) {
                [UIAlertView showWithTitle:@"Your password was changed" message:@"Please sign in with new password" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     [APPSHARE configMenuSideWithOrder:nil];
                }];
            }
        }];
    }
}

-(void)getBackLogin:(BaseView*)view
{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:view];
    APPSHARE.jaSide.centerPanel = nav;
    APPSHARE.jaSide.leftPanel = nil;
}

#pragma mark - DELEGATES

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}


@end
