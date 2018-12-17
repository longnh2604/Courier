//
//  VCListCard.h
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCListCardDelegate <NSObject>
@optional

- (void)choosedCard:(OPayment*)payment;

@end

@interface VCListCard : BaseView

@property (nonatomic, assign) BOOL isChooseCard;
@property (nonatomic, assign) id<VCListCardDelegate>delegate;

@end
