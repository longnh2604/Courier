//
//  PackageCell.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbPackage;
@property (weak, nonatomic) IBOutlet UILabel *lbNote;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UIImageView *imvNote;



@end
