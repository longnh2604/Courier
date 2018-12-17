//
//  VCWelcome.m
//  Delivery
//
//  Created by Long Nguyen on 12/23/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import "VCBlockAccount.h"

@interface VCBlockAccount ()

@property (weak, nonatomic) IBOutlet UILabel *lbMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;


@end

@implementation VCBlockAccount

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"AUTHORIZATION";
    self.lbMessage.text = @"Your account is blocked !";
    RESIGN_KEYBOARD
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(selectedBackButton:)];
    self.navigationItem.leftBarButtonItem = item;
    
    self.btnCall.layer.cornerRadius = 25;
    self.btnCall.layer.masksToBounds = YES;
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

#pragma mark - ACTIONS

- (void)selectedBackButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectedCallButton:(id)sender {
    NSURL *urlPhone = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",officePhone]];
    if ([[UIApplication sharedApplication] canOpenURL:urlPhone]) {
        [[UIApplication sharedApplication] openURL:urlPhone];
    }
}


#pragma mark - DELEGATES


@end
