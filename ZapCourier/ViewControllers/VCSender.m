//
//  VCSender.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCSender.h"
#import "DefaultButton.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface VCSender ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbSenderName;

@property (weak, nonatomic) IBOutlet DefaultButton *btnCallSender;
@property (weak, nonatomic) IBOutlet DefaultButton *btnSendSMS;

@end

@implementation VCSender

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Sender";
    NSLog(@"link image %@",self.senderAvatar);
    [self.imvAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.senderAvatar]] placeholderImage:avatarPlaceHolder];
    self.imvAvatar.layer.cornerRadius = self.imvAvatar.width/2;
    self.imvAvatar.layer.masksToBounds = YES;
    self.imvAvatar.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
    self.imvAvatar.layer.borderWidth = 2;
    
    self.lbSenderName.text = self.senderName;
    [self.btnCallSender addTarget:self action:@selector(onCallSender) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSendSMS addTarget:self action:@selector(onSendSMS) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

#pragma mark - ACTIONS

#pragma mark - DELEGATES

- (void)onSendSMS
{
    [self showSMS:@"content"];
}

-(void)onCallSender
{
    NSString *phNo = [NSString stringWithFormat:@"%@",self.senderPhone];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
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

//Message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(NSString*)file
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[self.senderPhone];
    NSString *message = @"Please input your message to us here !";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

@end
