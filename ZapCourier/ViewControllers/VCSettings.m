//
//  VCSettings.m
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCSettings.h"
#import "ButtonCell.h"
#import "PhoneCell.h"
#import "EmailCell.h"
#import "VCChangePhone.h"
#import "VCChangePassword.h"
#import "HCSStarRatingView.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface VCSettings ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;

@property (weak, nonatomic) IBOutlet UILabel *lbVersion;
@property (weak, nonatomic) IBOutlet UIButton *btnChangePass;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneContact;
@property (weak, nonatomic) IBOutlet UIButton *btnMailContact;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnMailLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreReview;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starReview;

@end

@implementation VCSettings

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Setting";
    self.imvAvatar.layer.cornerRadius = self.imvAvatar.width/2;
    self.imvAvatar.layer.masksToBounds = YES;
    self.imvAvatar.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.imvAvatar.layer.borderWidth = 2;
    
    [self.btnMailLabel setTitle:officeMail forState:UIControlStateNormal];
    [self.btnPhoneLabel setTitle:officePhone forState:UIControlStateNormal];
    
    [self.btnPhoneContact addTarget:self action:@selector(selectedPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPhoneLabel addTarget:self action:@selector(selectedPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMailContact addTarget:self action:@selector(selectedMail) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMailLabel addTarget:self action:@selector(selectedMail) forControlEvents:UIControlEventTouchUpInside];
    
    if (APPSHARE.userLogin!=nil) {
        self.lbName.text = [NSString stringWithFormat:@"%@ %@",APPSHARE.userLogin.firstName,APPSHARE.userLogin.lastName];
        self.lbPhone.text = APPSHARE.userLogin.phone;
        [self.imvAvatar sd_setImageWithURL:[NSURL URLWithString:APPSHARE.userLogin.photo] placeholderImage:avatarPlaceHolder];
    }
    
    self.starReview.value = 3.5;
    self.scoreReview.text = @"3.5";
    
    [self.btnChangePass addTarget:self action:@selector(onChangePass) forControlEvents:UIControlEventTouchUpInside];
#ifdef STAGGING
    self.lbVersion.text = [NSString stringWithFormat:@"Version %@(%@) Development",APP_VERSION,APP_BUILD];
#else
    self.lbVersion.text = [NSString stringWithFormat:@"Version %@",APP_VERSION];
#endif
    
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

#pragma mark - ACTIONS

#pragma mark - DELEGATES

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexpath %ld",(long)indexPath.row);
    return 60;
}

- (void)onChangePass
{
    VCChangePassword *change = VCUSER(VCChangePassword);
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:change];
    [self presentViewController:nav animated:YES completion:nil];
}

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
