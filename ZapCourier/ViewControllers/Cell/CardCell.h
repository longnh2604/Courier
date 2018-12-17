//
//  CardCell.h
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lbMask;
@property (nonatomic, weak) IBOutlet UIImageView *imvPhoto;
@property (nonatomic, weak) IBOutlet UILabel *lbExp;
@property (weak, nonatomic) IBOutlet UILabel *lbPrimary;


@end
