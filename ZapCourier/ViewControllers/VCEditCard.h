//
//  VCEditCard.h
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCEditCardDelegate <NSObject>
@optional

- (void)editCardDone:(OPayment*)payment;

@end

@interface VCEditCard : BaseView

@property (nonatomic, assign) int cardIdx;

@property (nonatomic, assign) BOOL isFromPresent;
@property (nonatomic, assign) id<VCEditCardDelegate>delegate;

@end
