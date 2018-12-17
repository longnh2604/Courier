//
//  VCChangePassword.m
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCChangePassword.h"
#import "VCLogin.h"

@interface VCChangePassword ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfCurrent;
@property (weak, nonatomic) IBOutlet UITextField *tfNew;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirm;

@end

@implementation VCChangePassword

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(selectedBackButton:)];
    self.navigationItem.leftBarButtonItem = item;
    
    //
    self.title = @"Change password";
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

- (BOOL)validatePassword{
    if (self.tfCurrent.text.length<6) {
        [UIAlertView showErrorWithMessage:@"Your password must be at least 6 characters" handler:nil];
        return NO;
    }
    if (self.tfNew.text.length<6 || self.tfConfirm.text.length<6) {
        [UIAlertView showErrorWithMessage:@"Your new password must be at least 6 characters" handler:nil];
        return NO;
    }
    if (![self.tfNew.text isEqualToString:self.tfConfirm.text]) {
        [UIAlertView showErrorWithMessage:@"Confirm password did not match" handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS

- (void)selectedBackButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)selectedChangeButton:(id)sender {
    if ([self validatePassword]) {
        [HServiceAPI changePasswordWithCurrent:self.tfCurrent.text new:self.tfNew.text handler:^(BOOL finish, NSError *error) {
            if (finish) {
                [UIAlertView showWithTitle:@"Your password was changed" message:@"Please sign in with new password" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                {
                    [HServiceAPI logout:^(BOOL finish, NSError *error) {
                    }];
                    [[AuthManager shared] logout];
                    APPSHARE.userLogin = nil;
                    [OOrderAvailable deleteAllOrder];
                    
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
    if (self.tfCurrent == textField) {
        [self.tfNew becomeFirstResponder];
    }else if (self.tfNew == textField){
        [self.tfConfirm becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}


@end
