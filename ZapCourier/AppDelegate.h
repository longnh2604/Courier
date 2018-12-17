//
//  AppDelegate.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) JASidePanelController *jaSide;
@property (nonatomic, assign) appState state;
@property (nonatomic, strong) OUserLogin *userLogin;
@property (nonatomic, strong) OOrderAvailable *currentOrder;
@property (nonatomic, strong) NSMutableDictionary *tempData;
@property (nonatomic, retain) NSString *oidNotify;
@property (nonatomic, retain) NSString *appState;
@property (nonatomic, retain) NSString *checkAdmin;
@property (nonatomic, retain) NSString *fwNotify;
@property (assign) BOOL isWork;
@property (nonatomic, retain) NSMutableArray *arrUserLocation;
@property (nonatomic, assign) CGFloat tempLate;
@property (nonatomic, assign) CGFloat tempLong;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

- (void)showBlock;
- (void)showLogin;
- (void)configMenuSideWithOrder:(OOrderAvailable*)curOrder;
- (void)addLeftPanelwithOrder:(OOrderAvailable*)curOrder;
- (void)addLeftPanelOnly;
- (void)addLeftPanelwithBulkOrder:(OBulk*)curOrder;
- (void)showVerifyPhone;
- (void)checkActiveOrder:(BOOL)value;
- (void)showFromNotification:(NSString *)oid;
- (void)clearBulkOrder;
-(void)checkNetwork;

@end

