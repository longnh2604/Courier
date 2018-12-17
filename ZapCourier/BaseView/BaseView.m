//
//  BaseView.m
//  Property
//
//  Created by Long Nguyen on 13/04/2015.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import "BaseView.h"
#import "VCLogin.h"
#import "VCOrderAvailableDetail.h"
#import "UIView+Toast.h"
#import "VCAvailableOrder.h"
#import "VCOrderBulkAssign.h"
#import "VCOrderAssign.h"

@implementation BaseView


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fixDropScroll];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Util clearCacheImage];
    [APPSHARE checkNetwork];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:@"userDidLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    if (self.navigationController.viewControllers.count>1)
    {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
        [btn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)fixDropScroll {
    float fVersion =[[[UIDevice currentDevice] systemVersion] floatValue];
    if (fVersion>=7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Method

-(UIToolbar*)createToolbarCancelForKeyBoard{
    self.vToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_PORTRAIT, 44)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectedHideKeyBoardButton:)];
    
    self.vToolbar.items = @[flex,done];
    return self.vToolbar;
}
-(void)selectedHideKeyBoardButton:(UIButton*)button{
    RESIGN_KEYBOARD
    self.vToolbar = nil;
}

#pragma mark - FUNCTIONS
-(void)showCenterView:(BaseView*)view{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:view];
    APPSHARE.jaSide.centerPanel = nav;
    [APPSHARE.jaSide showCenterPanelAnimated:YES];
}

///border

-(void)createBorderWithLabel:(UILabel*)label{
    CGFloat borderWidth = 1.0;
    
    label.layer.borderColor = [UIColor lightGrayColor].CGColor;
    label.layer.borderWidth = borderWidth;
    
    UIView* mask = [[UIView alloc] initWithFrame:CGRectMake(0, borderWidth, label.frame.size.width, label.frame.size.height-borderWidth)];
    mask.backgroundColor = [UIColor blackColor];
    label.layer.mask = mask.layer;
}


#pragma mark - ACTIONS

- (void)userDidLogout
{
    
}

- (IBAction)selectedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getBackLogin:(BaseView*)view
{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:view];
    APPSHARE.jaSide.centerPanel = nav;
    APPSHARE.jaSide.leftPanel = nil;
}

- (void)errorHandler:(NSError *)error
{
    DLog(@"error = %@",error.localizedDescription);
    if (error == nil || error.userInfo == nil) return;
    [[Util sharedUtil] hideLoading];
    id jsonResponse = [HServiceAPI convertToJson:error.userInfo];
    NSString *codeString = [jsonResponse stringForKey:@"code"];
    if ([@"account_blocked" isEqualToString:codeString]) {
        [[AuthManager shared] logout];
        //show block window
        [APPSHARE showBlock];
        return;
    }
    
    if ([@"new_token_required" isEqualToString:codeString]) {
        // Posting notification to VCOrderAssign controller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_timer_if_waiting_time_return_trip" object:@"stop_timer_if_waiting_time_return_trip" userInfo:nil];
        //Logout account
        [HServiceAPI logout:^(BOOL finish, NSError *error) {
        }];
        [[AuthManager shared] logout];
        [OOrderAvailable deleteAllOrder];
        [APPSHARE configMenuSideWithOrder:nil];
        return;
    }
    if (jsonResponse && [[jsonResponse objectForKey:@"detail"]rangeOfString:@"Not found"].location != NSNotFound)
    {
        //If not found then Switch to Available Orders
        [OOrderAvailable deleteAllOrder];
        [[WatchManager shared] completeOrder];
        [APPSHARE checkActiveOrder:NO];
        [APPSHARE addLeftPanelwithOrder:nil];
        return;
    }
    
    //Show error detail via Toast
    if (jsonResponse && [jsonResponse objectForKey:@"detail"]) {
        //[error localizedDescription]
        [self.view makeToast:[jsonResponse stringForKey:@"detail"] duration: 3.0 position:CSToastPositionTop];
    }
}

#pragma mark - Network

- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)[notification object];
    if ([reachability isReachable]) {
        DLog(@"Reachable");
        UIView *v = [APPSHARE.jaSide.centerPanel.view viewWithTag:99999];
        if (v!=nil){
            [self removeNoConnection];
            if ([APPSHARE.jaSide.centerPanel isKindOfClass:[UINavigationController class]]) {
                if (![APPSHARE.userLogin.proBasket isEqualToString:@""])
                {
                    [HServiceAPI getCurrentActiveBulkOrder:^(NSDictionary *results, NSError *error) {
                        if (!error)
                        {
                            [APPSHARE checkActiveOrder:YES];
                            OBulk *o = [OBulk convertToObject:results];
                            [OBulk saveOrder:o];
                            RELOAD_MENU_LEFT
                            if ([((UINavigationController*)APPSHARE.jaSide.centerPanel).topViewController isKindOfClass:[VCAvailableOrder class]] || [((UINavigationController*)APPSHARE.jaSide.centerPanel).topViewController isKindOfClass:[VCOrderBulkAssign class]]) {
                                [APPSHARE addLeftPanelwithBulkOrder:o];
                            }
                        }
                    }];
                }else if (APPSHARE.userLogin.proOrder){
                    [HServiceAPI getActiveOrderDetails:^(NSDictionary *results, NSError *error)
                     {
                         if (results!=nil)
                         {
                             [APPSHARE checkActiveOrder:YES];
                             OOrderAvailable *curOrder = [OOrderAvailable convertToObject:results];
                             [OOrderAvailable saveOrder:curOrder];
                             RELOAD_MENU_LEFT
                             
                             if ([((UINavigationController*)APPSHARE.jaSide.centerPanel).topViewController isKindOfClass:[VCAvailableOrder class]] || [((UINavigationController*)APPSHARE.jaSide.centerPanel).topViewController isKindOfClass:[VCOrderAssign class]]) {
                                 [APPSHARE addLeftPanelwithOrder:curOrder];
                             }
                         }
                     }];
                }
            }
        }
    } else {
        DLog(@"Unreachable");
        [self showNoConnection];
    }
}
- (void)showNoConnection{
    UIView *v = [APPSHARE.jaSide.centerPanel.view viewWithTag:99999];
    if (v==nil){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 32, SCREEN_WIDTH, 30)];
        view.backgroundColor = [UIColor clearColor];
        view.tag = 99999;
        
        UIView *bg = [[UIView alloc]initWithFrame:view.frame];
        bg.backgroundColor = [UIColor blackColor];
        bg.alpha = 0.8;
        [view addSubview:bg];
        
        UILabel *lb = [[UILabel alloc]initWithFrame:view.frame];
        lb.backgroundColor = [UIColor clearColor];
        lb.text = @"No internet connection";
        lb.font = [UIFont systemFontOfSize:12];
        lb.textColor = [UIColor whiteColor];
        lb.textAlignment = NSTextAlignmentCenter;
        [view addSubview:lb];
        
        [APPSHARE.jaSide.centerPanel.view addSubview:view];
    }
}

- (void)removeNoConnection{
    UIView *view = [APPSHARE.jaSide.centerPanel.view viewWithTag:99999];
    [view removeFromSuperview];
}
@end
