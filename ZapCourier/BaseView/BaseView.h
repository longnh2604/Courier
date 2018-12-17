//
//  BaseView.h
//  Property
//
//  Created by Long Nguyen on 13/04/2015.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseView : UIViewController

@property (nonatomic, strong) UIToolbar *vToolbar;

-(void)showCenterView:(BaseView*)view;
-(UIToolbar*)createToolbarCancelForKeyBoard;
- (void)errorHandler:(NSError *)error;

@end
