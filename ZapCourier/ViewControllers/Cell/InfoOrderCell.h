//
//  InfoOrderCell.h
//  Delivery
//
//  Created by Long Nguyen on 12/30/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoOrderDelegate <NSObject>

- (void)beginEditingWithIndex:(NSIndexPath*)idx;
- (void)updateInfoOrderWithInfo:(NSString*)info index:(NSIndexPath*)idx;

@end

@interface InfoOrderCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, assign) id<InfoOrderDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIImageView *imvIcon;
@property (nonatomic, weak) IBOutlet UIButton *btnCountryCode;
@property (nonatomic, weak) IBOutlet UITextField *tfInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthBtnCountryCode;

@property (nonatomic, strong) NSIndexPath *idx;
@property (nonatomic, assign) BOOL isSender;
@property (nonatomic, assign) BOOL isPhone;
@property (nonatomic, assign) BOOL isNote;

- (void)setInfo:(BOOL)phone forName:(NSString*)strName forPhone:(NSString*)strPhone sender:(BOOL)sender index:(NSIndexPath*)idx;
- (void)setInfoNote:(NSString*)note index:(NSIndexPath*)idx;

@end
