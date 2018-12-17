//
//  MenuCell.h
//  Delivery
//
//  Created by Long Nguyen on 12/29/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imvIcon;
@property (nonatomic, weak) IBOutlet UILabel *lbTitle;
@property (nonatomic, weak) IBOutlet UILabel *lbBg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scSegment;
@property (nonatomic, assign) BOOL isActive;

- (void)setMenuActive:(BOOL)active menu:(NSString*)name icon:(NSString*)icon;


@end
