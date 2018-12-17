//
//  VCSettings.m
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCPermission.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface VCPermission ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;

@property (weak, nonatomic) IBOutlet UIButton *btnPhoneContact;
@property (weak, nonatomic) IBOutlet UIButton *btnMailContact;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnMailLabel;

@end

@implementation VCPermission

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Zap Courier";
    
    [self.btnPhoneLabel setTitle:officePhone forState:UIControlStateNormal];
    [self.btnMailLabel setTitle:officeMail forState:UIControlStateNormal];
    
    [self.btnPhoneContact addTarget:self action:@selector(selectedPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPhoneLabel addTarget:self action:@selector(selectedPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMailContact addTarget:self action:@selector(selectedMail) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMailLabel addTarget:self action:@selector(selectedMail) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

#pragma mark - ACTIONS

-(void)selectedPhone
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",officePhone]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl])
    {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"Call facility is not available!"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)selectedMail
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:@[officeMail]];
        [mailViewController setSubject:@""];
        [mailViewController setMessageBody:@"" isHTML:NO];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Device is unable to send email in its current state.");
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error with message" message:[NSString stringWithFormat:@"Error %@", [error description]] delegate:nil cancelButtonTitle:@"Try Again Later!" otherButtonTitles:nil, nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
