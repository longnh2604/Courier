//
//  DateCardCell.h
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateCardDelegate <NSObject>
@required

- (void)endEditingDateCardDelegate:(NSString*)month year:(NSString*)year cvv:(NSString*)cvv;

@end

@interface DateCardCell : UITableViewCell<UITextFieldDelegate>


@property (nonatomic, assign) id<DateCardDelegate>delegate;

@property (nonatomic, weak) IBOutlet UITextField *tfMonth;
@property (nonatomic, weak) IBOutlet UITextField *tfYear;
@property (nonatomic, weak) IBOutlet UITextField *tfCVV;


- (void)configCell:(NSString*)month year:(NSString*)year cvv:(NSString*)cvv;

@end
