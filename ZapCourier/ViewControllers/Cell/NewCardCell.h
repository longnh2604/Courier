//
//  NewCardCell.h
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewCardDelegate <NSObject>
@required

- (void)endEditingInfoWithIndex:(NSIndexPath*)index string:(NSString*)text;

@end

@interface NewCardCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, assign) id<NewCardDelegate>delegate;
@property (nonatomic, weak) IBOutlet UITextField *tfInfo;
@property (nonatomic, strong) NSIndexPath *idx;

- (void)setLayoutWithIdx:(NSIndexPath*)idx number:(NSString*)number;

@end
