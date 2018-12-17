//
//  VCRatingPopUp.h
//  Delivery
//
//  Created by Harry Nguyen on 4/29/16.
//  Copyright © 2016 Harry Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

@protocol VCRatingPopUpDelegate <NSObject>
@required

- (void)VCRatingPopUpSelectedCancelButton;
- (void)VCRatingPopUpSelectedSubmitButtonWithStar:(NSString*)star comment:(NSString*)comment;

@end

@interface VCRatingPopUp : UIViewController

@property (nonatomic, assign) id<VCRatingPopUpDelegate>delegate;
@property (nonatomic, strong) UIToolbar *vToolbar;

@property (weak, nonatomic) IBOutlet UIView *vBackground;

@property (weak, nonatomic) IBOutlet UIView *vPopUp;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbMessage;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *vStar;
@property (weak, nonatomic) IBOutlet UILabel *lbStar;


@property (weak, nonatomic) IBOutlet UIView *vComment;
@property (weak, nonatomic) IBOutlet UILabel *lbPlaceHolderTextView;
@property (weak, nonatomic) IBOutlet UITextView *tvComment;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end
