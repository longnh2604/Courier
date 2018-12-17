//
//  SizeCell.h
//  Delivery
//
//  Created by Long Nguyen on 12/29/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SizeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imvSize;
@property (nonatomic, weak) IBOutlet UILabel *lbPack;
@property (nonatomic, weak) IBOutlet UILabel *lbSize;
@property (nonatomic, weak) IBOutlet UILabel *lbWeight;
@property (nonatomic, weak) IBOutlet UILabel *lbGuide;
@property (nonatomic, weak) IBOutlet UILabel *lbPrice;
@property (nonatomic, weak) IBOutlet UILabel *lbCurrency;

@property (nonatomic, weak) IBOutlet UIView *vPack;
@property (nonatomic, weak) IBOutlet UIView *vPrice;


- (void)configCell:(BOOL)active info:(NSDictionary*)info withPrice:(NSString*)price;

@end
