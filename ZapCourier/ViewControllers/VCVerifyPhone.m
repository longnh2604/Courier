//
//  VCVerifyPhone.m
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCVerifyPhone.h"
#import "DefaultButton.h"
#import "VCChangeForgotPassword.h"
#import "VCPersonalDetail.h"

@interface VCVerifyPhone ()<UITextFieldDelegate>{
    NSTimer *timer;
    NSString *code;
    int timeLeft;
}

@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmCode;

@property (weak, nonatomic) IBOutlet DefaultButton *btnResend;



@end

@implementation VCVerifyPhone

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Confirm your number";
    self.lbPhone.text = self.strPhone;
    [self.tfConfirmCode becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    if ([self checkTimeResend]) {
        [timer invalidate];
        timer = nil;
        timeLeft = 0;
        [self enableResendButton:YES];
    }else{
        [self startTimer];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
}

#pragma mark - LAYOUT

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    RESIGN_KEYBOARD
}

- (void)startTimer{
    [timer invalidate];
    [self enableResendButton:NO];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^{
        timeLeft--;
        if (timeLeft<=0) {
            [self enableResendButton:YES];
            [timer invalidate];
            timer = nil;
        }else{
            [self enableResendButton:NO];
            [self.btnResend setTitle:[NSString stringWithFormat:@"You can resend the code again in %d seconds",timeLeft] forState:UIControlStateNormal];
        }
    }];
}

- (void)enableResendButton:(BOOL)enable{
    self.btnResend.enabled = enable;
    if (enable) {
        [self.btnResend setTitle:@"RESEND THE CODE" forState:UIControlStateNormal];
        [self.btnResend setBackgroundColor:UIColorFromRGB(0x0098FC)];
    }else{
        [self.btnResend setBackgroundColor:UIColorFromRGB(0xb2b2b2)];
    }
}

#pragma mark - FUNCTIONS

- (BOOL)checkTimeResend{
    NSString *strTime = [[AuthManager shared] getTimeResendCode];
    
    if (strTime.length>0) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval start = strTime.floatValue;
        double deltaSeconds = fabs(now - start);
        
        if (deltaSeconds>phoneCodeResendInterval) {
            timeLeft = 0;
            return YES;
        }else{
            timeLeft = phoneCodeResendInterval;
            return NO;
        }
    }else{
        timeLeft = phoneCodeResendInterval;
        return NO;
    }
    
}

- (void)verify
{
    if (self.isForgot)
    {
        [HServiceAPI changeForgotPassword:self.strPhone code:code new:@"" handler:^(BOOL finish, NSError *error)
        {
            if (!error)
            {
                [Util removeObjectForKey:timeResendCode];
                VCChangeForgotPassword *new = VCUSER(VCChangeForgotPassword);
                new.strPhone = self.strPhone;
                new.strCode = code;
                [self.navigationController pushViewController:new animated:YES];
            }
        }];
    }
    else
    {
        [HServiceAPI confirmCode:code success:^(BOOL success) {
            if (success)
            {
                [Util removeObjectForKey:timeResendCode];
                VCPersonalDetail *pd= VCUSER(VCPersonalDetail);
                [self.navigationController pushViewController:pd animated:YES];
            }
        }];
    }
    RELOAD_MENU_LEFT
}

#pragma mark - ACTIONS
- (IBAction)selectedResendButton:(id)sender
{
    if (self.isForgot)
    {
        [HServiceAPI verifyPhoneNumber:self.strPhone success:^(BOOL success) {
            if (success) {
                [Util setObject:[NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]] forKey:timeResendCode];
                timeLeft = phoneCodeResendInterval;
                [self startTimer];
            }
        }];
    }
    else
    {
        [HServiceAPI onRequestConfirmCode:self.strPhone success:^(BOOL success)
         {
             if (success)
             {
                 [Util setObject:[NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]] forKey:timeResendCode];
                 timeLeft = phoneCodeResendInterval;
                 [self startTimer];
             }
             else
             {
                 DLog(@"failed request confirm code");
             }
         }];
        
    }
}

#pragma mark - DELEGATES

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (strFinal.length>phoneCodeLength) {
        return NO;
    }else if (strFinal.length==phoneCodeLength) {
        code = strFinal;
        [self verify];
    }
    
    return YES;
}

@end
