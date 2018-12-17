//
//  VCMenu.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/25/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCMenu.h"
#import "MenuCell.h"
#import "UserCell.h"
#import "MenuSignInCell.h"

#import "VCLogin.h"
#import "VCSettings.h"
#import "VCListCard.h"
#import "VCHistory.h"
#import "VCMyRewards.h"
#import "VCAvailableOrder.h"
#import "VCOrderAssign.h"
#import "VCOrderBulkAssign.h"
#import "VCBulkHistory.h"

#define mnAvailableOrder            @"Available Orders"
#define mnActiveOrder               @"Active Order"
#define mnHistory                   @"Order History"
#define mnMyRewards                 @"My Rewards"
#define mnCalltheOffice             @"Call the Office"
#define mnAvailable                 @"Available"
#define mnSettings                  @"Settings"
#define mnLogout                    @"Logout"

@interface VCMenu ()<UITableViewDataSource,UITableViewDelegate>{
    NSArray *arMenu;
    NSArray *arMenuIcon;
    NSString *checkMode;
}

@property (nonatomic,weak) IBOutlet UITableView *tbMenu;

@end

@implementation VCMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMenu) name:@"reloadMenuLeft" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkingMode) name:@"workMode" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOfflineMode) name:@"offlineMode" object:nil];
    [self setLayout];
}

-(void)onWorkingMode
{
    APPSHARE.isWork = YES;
    checkMode = @"work";
    [self.tbMenu reloadData];
}

-(void)onOfflineMode
{
    APPSHARE.isWork = NO;
    checkMode = @"offline";
    [self.tbMenu reloadData];
}

#pragma mark - LAYOUT

- (void)setLayout{
    if ([self checkLogin])
    {
        if (APPSHARE.userLogin.is_approved)
        {
            arMenu = @[([self checkHaveOrder])?mnActiveOrder:mnAvailableOrder,mnHistory,mnMyRewards,mnCalltheOffice,mnAvailable,mnSettings,mnLogout];
            arMenuIcon = @[@"icon_order",@"icon_history",@"icon_payment",@"icon_calltheoffice",@"icon_available",@"icon_settings",@"icon_logout"];
        }
        else
        {
            arMenu = @[mnLogout];
            arMenuIcon = @[@"icon_logout"];
        }
    }
    else
    {
        arMenu = @[mnAvailableOrder];
        arMenuIcon = @[@"icon_order"];
    }
    [self.tbMenu reloadData];
}

- (BOOL)checkHaveOrder
{
    if (APPSHARE.userLogin.activeOrder)
    {
        DLog(@"%@",APPSHARE.userLogin);
        NSLog(@"co order");
        return YES;
    }
    else
    {
        DLog(@"%@",APPSHARE.userLogin);
        NSLog(@"ko co order");
        return NO;
    }
}

#pragma mark - FUNCTIONS

- (BOOL)checkLogin{
    if (APPSHARE.userLogin==nil) {
        return NO;
    }else{
        return YES;
    }
}
-(void)showCenterView:(BaseView*)view{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:view];
    APPSHARE.jaSide.centerPanel = nav;
    [APPSHARE.jaSide showCenterPanelAnimated:YES];
    [self.tbMenu reloadData];
}

-(void)getBackLogin:(BaseView*)view
{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:view];
    APPSHARE.jaSide.centerPanel = nav;
    APPSHARE.jaSide.leftPanel = nil;
}

- (void)reloadMenu{
    [self setLayout];
}


#pragma mark - ACTIONS

- (void)selectedSignInButton:(UIButton*)button{
    DLog(@"login");
    [APPSHARE showLogin];
}

#pragma mark - DELEGATES

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self checkLogin]){
        return arMenu.count + 1;
    }else{
        return arMenu.count + 2;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0){
        return 230;
    }else if (indexPath.row == arMenu.count+1) {
        return 77;
    }else{
        return 54;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0)
    {
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        if (!cell) {
            cell = [[UserCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
        }
        
        if ([self checkLogin]) {
            [cell.imvAvatar sd_setImageWithURL:[NSURL URLWithString:APPSHARE.userLogin.photo] placeholderImage:avatarPlaceHolder];
            cell.lbName.text = [NSString stringWithFormat:@"%@ %@",APPSHARE.userLogin.firstName,APPSHARE.userLogin.lastName];
            cell.lbPhone.text = APPSHARE.userLogin.phone;
        }
        [cell showAvatar:[self checkLogin]];
        
        return cell;
    }
    else if(indexPath.row<=arMenu.count)
    {
        MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
        if (!cell) {
            cell = [[MenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];
        }
        
        NSInteger idx = (indexPath.row-1);
        
        [cell setMenuActive:(APPSHARE.state==idx)?YES:NO menu:arMenu[idx] icon:arMenuIcon[idx]];
        
        if (idx == 4)
        {
            if (APPSHARE.isWork)
            {
                cell.scSegment.selectedSegmentIndex = 1;
            }
            else
            {
                cell.scSegment.selectedSegmentIndex = 0;
            }
            
            cell.scSegment.hidden = NO;
            [cell.scSegment addTarget:self
                               action:@selector(selectedAvailable:)
                     forControlEvents:UIControlEventValueChanged];
            [cell.scSegment.layer setCornerRadius:5.0f];
            
            //set custom separator for cell
            UIView * additionalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,cell.frame.size.height-1,cell.frame.size.width,3)];
            additionalSeparator.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:234.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
            [cell addSubview:additionalSeparator];
        }
        if (APPSHARE.userLogin.activeOrder)
        {
            cell.scSegment.enabled = NO;
        }
        else
        {
            cell.scSegment.enabled = YES;
        }
        
        return cell;
    }else{
        MenuSignInCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuSignInCell"];
        if (!cell) {
            cell = [[MenuSignInCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuSignInCell"];
        }
        [cell.btnSignIn addTarget:self action:@selector(selectedSignInButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0)
    {
        //user
    }else if (indexPath.row<=arMenu.count)
    {
        NSInteger idx = (indexPath.row-1);
            
        if ([arMenu[idx] isEqualToString:mnAvailableOrder] || [arMenu[idx] isEqualToString:mnActiveOrder])
        {
            //create order
            APPSHARE.state = sList;
            OOrderAvailable *currentOrder = [OOrderAvailable getCurrentOrder];
            if (currentOrder==nil)
            {
                VCAvailableOrder *vc = VCAVAILABEL(VCAvailableOrder);
                [self showCenterView:vc];
            }
            else
            {
                if (![APPSHARE.userLogin.proBasket isEqualToString:@""])
                {
                    VCOrderBulkAssign *vc = VCORDERBULK(VCOrderBulkAssign);
                    [self showCenterView:vc];
                    OBulk *order = [OBulk getCurrentOrder];
                    vc.currentOrder = order;
                }
                else
                {
                    VCOrderAssign *vc = VCORDER(VCOrderAssign);
                    [self showCenterView:vc];
                    OOrderAvailable *order = [OOrderAvailable getCurrentOrder];
                    vc.currentOrder = order;
                }
            }
        }else if ([arMenu[idx] isEqualToString:mnHistory]) {
            
            if (![self checkLogin]) {
                return;
            }
            //history
            APPSHARE.state = sHistory;
            VCBulkHistory *history = VCAVAILABEL(VCBulkHistory);
            [self showCenterView:history];
            
        }else if ([arMenu[idx] isEqualToString:mnMyRewards]) {
            
            if (![self checkLogin]) {
                return;
            }
            APPSHARE.state = sRewards;
            VCMyRewards *myRewards = VCSETTING(VCMyRewards);
            [self showCenterView:myRewards];
            
        }else if ([arMenu[idx] isEqualToString:mnCalltheOffice]) {
            
            if (![self checkLogin]) {
                return;
            }

            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",officePhone]];
            
            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                [[UIApplication sharedApplication] openURL:phoneUrl];
            } else
            {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Alert"
                                              message:@"Call facility is not available!"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"OK action");
                                           }];
                
                [alert addAction:okAction];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }else if ([arMenu[idx] isEqualToString:mnAvailable]) {
            
            if (![self checkLogin]) {
                return;
            }

            
        }else if ([arMenu[idx] isEqualToString:mnSettings]) {
            if (![self checkLogin]) {
                return;
            }
            //settings
            APPSHARE.state = sSetting;
            VCSettings *st = VCSETTING(VCSettings);
            [self showCenterView:st];
            
        }else if ([arMenu[idx] isEqualToString:mnLogout]) {
            //logout
            [UIAlertView showConfirmationDialogWithTitle:@"Are you sure?" message:@"" handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 if (buttonIndex==1) {
                     [HServiceAPI logout:^(BOOL finish, NSError *error) {
                     }];
                     [[AuthManager shared] logout];
                     [OOrderAvailable deleteAllOrder];
                     VCLogin *login = VCUSER(VCLogin);
                     [self getBackLogin:login];
                     RELOAD_MENU_LEFT
                 }
             }];
        }
    }else{
        [self selectedSignInButton:nil];
    }
}

- (void)selectedAvailable:(UISegmentedControl *)sender
{
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    if (selectedSegment == 1)
    {
        APPSHARE.isWork = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"workStatus" object:nil];
    }
    else
    {
        APPSHARE.isWork = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"offlineStatus" object:nil];
    }
}

@end

