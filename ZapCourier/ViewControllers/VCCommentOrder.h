//
//  VCCommentOrder.h
//  Delivery
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCCommentDelegate <NSObject>
@required

- (void)didCommentWithReason:(NSString*)reason selected:(NSString*)selected;

@end

@interface VCCommentOrder : BaseView

@property (nonatomic, assign) id<VCCommentDelegate>delegate;


@end
