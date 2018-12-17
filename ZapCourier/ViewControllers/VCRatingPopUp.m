//
//  VCRatingPopUp.m
//  Delivery
//
//  Created by Harry Nguyen on 4/29/16.
//  Copyright © 2016 Harry Nguyen. All rights reserved.
//

#import "VCRatingPopUp.h"

static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);


@interface VCRatingPopUp ()<UITextViewDelegate>

@end

@implementation VCRatingPopUp

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configLayout];
    
    CGRect finalFrame = self.vPopUp.frame;
    finalFrame.origin.y = -self.view.height;
    self.vPopUp.frame = finalFrame;
    
    
    [UIView animateWithDuration:0.30
                          delay:0
                        options:kAnimationOptionCurveIOS7
                     animations:^{
                         CGRect finalFrame = self.vPopUp.frame;
                         finalFrame.origin.y = self.view.y;
                         self.vPopUp.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - LAYOUT

- (void)configLayout{
    self.vPopUp.layer.cornerRadius = 8;
    self.vPopUp.layer.masksToBounds = YES;
    
    self.vComment.layer.cornerRadius = 8;
    self.vComment.layer.masksToBounds = YES;
    self.vComment.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.vComment.layer.borderWidth = 1;
    
    self.tvComment.inputAccessoryView = [self createToolbarCancelForKeyBoard];
}

#pragma mark - FUNCTIONS

-(UIToolbar*)createToolbarCancelForKeyBoard{
    self.vToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_PORTRAIT, 44)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectedHideKeyBoardButton:)];
    
    self.vToolbar.items = @[flex,done];
    return self.vToolbar;
}
-(void)selectedHideKeyBoardButton:(UIButton*)button{
    RESIGN_KEYBOARD
    self.vToolbar = nil;
}


#pragma mark - ACTIONS

- (IBAction)selectedCancelButton:(id)sender{
    [self selectedHideKeyBoardButton:nil];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.delegate VCRatingPopUpSelectedCancelButton];
    }];
}
- (IBAction)selectedSubmitButton:(id)sender{
    [self selectedHideKeyBoardButton:nil];
    
    if (self.lbStar.text.floatValue<1.0f) {
        [UIAlertView showWarningWithMessage:@"You must rate at least 1 star" handler:nil];
        return;
    }
    if (self.tvComment.text.length<1 && self.lbStar.text.floatValue<4.0f) {
        [UIAlertView showWarningWithMessage:@"You must enter your comment" handler:nil];
        return;
    }
    
    //call api submit rate
    [self.delegate VCRatingPopUpSelectedSubmitButtonWithStar:self.lbStar.text comment:self.tvComment.text];
}

- (IBAction)changedValueStar:(HCSStarRatingView *)sender {
    self.lbStar.text = [NSString stringWithFormat:@"%.1f",sender.value];
}

#pragma mark - DELEGATES

//MARK: - UITextView
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.view.y==0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view setY:-100];
        }];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setY:0];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    DLog(@"textview.text=%@ --- range=%@ --- text=%@",textView.text,NSStringFromRange(range),text);
    NSString *strFinal = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (strFinal.length>0) {
        self.lbPlaceHolderTextView.hidden = YES;
    }else{
        self.lbPlaceHolderTextView.hidden = NO;
    }
    
    return YES;
}

@end
