//
//  TabView.h
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabViewDelegate <NSObject>
@required

- (void)tabViewSelectedButtonAtIndex:(int)idx;

@end

@interface TabView : UIView

@property (nonatomic, assign) id<TabViewDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIButton *btnBulk;
@property (nonatomic, weak) IBOutlet UIButton *btnSingle;
@property (nonatomic, weak) IBOutlet UILabel *lbSelected;
@property (nonatomic, assign) int selected;


- (void)updateViewWhenScrolling:(CGPoint)offset;

@end
