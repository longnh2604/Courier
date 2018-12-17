//
//  VCNewCard.h
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCAddNewCardDelegate <NSObject>
@optional

- (void)addNewCardDone:(OPayment*)payment;

@end

@interface VCNewCard : BaseView

@property (nonatomic, assign) id<VCAddNewCardDelegate>delegate;
@property (nonatomic, assign) BOOL isFromPresent;

@end
