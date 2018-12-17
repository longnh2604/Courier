//
//  VCCommentOrder.m
//  Delivery
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCCommentOrder.h"

@interface VCCommentOrder ()<UITextFieldDelegate>{
    NSString *strChoose;
}

@property (weak, nonatomic) IBOutlet UIButton *btnMyMind;
@property (weak, nonatomic) IBOutlet UIButton *btnCourierNotCome;
@property (weak, nonatomic) IBOutlet UIButton *btnAnother;

@property (weak, nonatomic) IBOutlet UITextField *tfReason;


@end

@implementation VCCommentOrder

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self checkedButton:self.btnMyMind];
    self.title = @"Cancellation Reason";
    
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(selectedCancelButton:)];
    self.navigationItem.leftBarButtonItem = itemLeft;
    
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectedDoneButton:)];
    self.navigationItem.rightBarButtonItem = itemRight;
}

#pragma mark - LAYOUT

- (void)checkedButton:(UIButton*)btn{
    self.tfReason.hidden = (btn == self.btnAnother)?NO:YES;
    [self.btnMyMind setImage:[UIImage imageNamed:(btn==self.btnMyMind)?@"btn_checked":@"btn_uncheck"] forState:UIControlStateNormal];
    [self.btnCourierNotCome setImage:[UIImage imageNamed:(btn==self.btnCourierNotCome)?@"btn_checked":@"btn_uncheck"] forState:UIControlStateNormal];
    [self.btnAnother setImage:[UIImage imageNamed:(btn==self.btnAnother)?@"btn_checked":@"btn_uncheck"] forState:UIControlStateNormal];
    
    if (btn == self.btnMyMind)
    {
        strChoose = @"CANT_PICKUP";
    }else if (btn == self.btnCourierNotCome)
    {
        strChoose = @"OTHER";
    }else if (btn == self.btnAnother)
    {
        strChoose = @"OTHER";
    }
}

#pragma mark - FUNCTIONS

#pragma mark - ACTIONS
- (IBAction)selectedChooseReason:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    [self checkedButton:btn];
}

- (void)selectedCancelButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectedDoneButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate didCommentWithReason:([strChoose isEqualToString:@"OTHER"])?self.tfReason.text:nil selected:strChoose];
}

#pragma mark - DELEGATES

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (strFinal.length>140) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
