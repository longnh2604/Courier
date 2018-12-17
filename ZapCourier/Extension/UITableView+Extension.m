//
//  UITableView+Extension.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/15/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "UITableView+Extension.h"

#define tagViewNoOrders         123123123

@implementation UITableView(Extension)

- (void)showNoOrdersView{
    [self removeNoOrdersView];
    [self showNoOrderWithString:@"No available orders"];
}

- (void)showNoCompletedOrdersView{
    [self removeNoOrdersView];
    [self showNoOrderWithString:@"No completed orders"];
}
- (void)showNoOrderWithString:(NSString*)string{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-((APPSHARE.userLogin.is_bulk)?50:0))];
    view.backgroundColor = UIColorFromRGB(0xf7f7f7);
    view.tag = tagViewNoOrders;
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    imv.image = [UIImage imageNamed:@"icon_nodata"];
    imv.center = view.center;
    [view addSubview:imv];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, view.height-50, view.width, 50)];
    label.backgroundColor = UIColorFromRGB(0x333333);
    label.font = [UIFont systemFontOfSize:18];
    label.text = string;
    label.textColor = UIColorFromRGB(0xffffff);
    label.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:label];
    
    [self addSubview:view];
}

- (void)removeNoOrdersView{
    UIView *view = [self viewWithTag:tagViewNoOrders];
    [view removeFromSuperview];
}

@end
