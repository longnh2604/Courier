//
//  UserCell.h
//  Delivery
//
//  Created by Long Nguyen on 12/29/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imvAvatar;
@property (nonatomic, weak) IBOutlet UILabel *lbName;
@property (nonatomic, weak) IBOutlet UILabel *lbPhone;

- (void)showAvatar:(BOOL)show;

@end
