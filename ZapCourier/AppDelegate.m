//
//  AppDelegate.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GAI.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "VCBlockAccount.h"
#import "VCMenu.h"
#import "VCLogin.h"
#import "VCSplash.h"
#import "VCOrderAssign.h"
#import "VCVerifyPhone.h"
#import "VCPermission.h"
#import "VCOrderAvailableDetail.h"

#import "VCAvailableOrder.h"
#import "VCOrderBulkAssign.h"

@import GoogleMaps;

@interface AppDelegate ()<CLLocationManagerDelegate,WCSessionDelegate>
{
    CLLocation *currentLocation;
    CLLocationManager * locationManager;
    NSTimer *timer;
}

@end

@implementation AppDelegate
@synthesize tempData,tempLate,tempLong;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    //config fabric
    [Fabric with:@[[Crashlytics class]]];
    
    // config for navigation bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(cBgNav)];
    [[UINavigationBar appearance] setTintColor:UIColorFromRGB(0xffeb3b)];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(cTextNav),
                                                           NSForegroundColorAttributeName,nil]];
    
    //config Google
    [GMSServices provideAPIKey:googleAPIs];
    
    //config google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:googleAnalytics];
    // migration realm when update database
    [self migrationDatabase];
    

    //user login
    self.userLogin = [OUserLogin getUserLogin];
    //show view
    [self showSplash];
    
    //for push notification local
    [[APNSManager shared] receiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
    [self startUpdating];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[WatchManager shared] enableWatchWithDelegate:self];
    
    return YES;
}

-(void)startUpdating
{
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

-(void)timerFired{
    [timer invalidate];
    timer = nil;
    [locationManager startUpdatingLocation];
}

// update location
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    if(locations.count)
    {
            // Optional: check error for desired accuracy
            currentLocation = (CLLocation *)[locations lastObject];
        
            self.arrUserLocation = [[NSMutableArray alloc]init];
            
            tempLate = currentLocation.coordinate.latitude;
            tempLong = currentLocation.coordinate.longitude;
            
            [self.arrUserLocation addObject:[NSString stringWithFormat:@"{\"type\": \"Point\",\"coordinates\":[%f,%f]}",tempLong,tempLate]];
        
            if (APPSHARE.userLogin == nil)
            {
            }
            else
            {
//                DLog(@"lat%f - lon%f", currentLocation.coordinate.longitude, currentLocation.coordinate.latitude);
                [manager stopUpdatingLocation];
                [HServiceAPI updateCurrentPosition:self.arrUserLocation success:^{
                    timer = [NSTimer scheduledTimerWithTimeInterval:currentOrderRefreshInterval target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
                    if (self.isWork) RELOAD_ORDER_AVAILABLE
                }];
            }
    }
}
- (void)migrationDatabase{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        [migration enumerateObjects:OUserLogin.className
                              block:^(RLMObject *oldObject, RLMObject *newObject) {
                                  if (oldSchemaVersion < 1) {
                                      newObject[@"is_bulk"] = [NSNumber numberWithBool:NO];
                                      newObject[@"proBasket"] = @"";
                                      newObject[@"proOrder"] = @"";
                                  }
                              }];
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
}

#pragma mark - Push notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[APNSManager shared] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[APNSManager shared] didFailToRegisterForRemoteNoficationWithError:error];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if([application applicationState] == UIApplicationStateActive)
    {
        // app was open, did not display the push alert/banner/badge
        // **Didn't click on notification**
        APPSHARE.appState = @"onActive";
        [[APNSManager shared] receiveRemoteNotification:userInfo];
    }
    else if ([application applicationState] == UIApplicationStateBackground)
    {
        //launched from push notification
        APPSHARE.appState = @"onBackground";
        [[APNSManager shared] receiveRemoteNotification:userInfo];
    }
    else if ([application applicationState] == UIApplicationStateInactive)
    {
        APPSHARE.appState = @"onInactive";
        [[APNSManager shared] receiveRemoteNotification:userInfo];
    }
    else
    {
        APPSHARE.appState = @"onOtherCase";
        [[APNSManager shared] receiveRemoteNotification:userInfo];
    }
}
#pragma mark - Application delegate

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //set badge number to 0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    //remove all notification from dash boards
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - Backgrounding Methods -
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    DLog(@"------------->handleEventsForBackgroundURLSession.......");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@"------------->applicationDidEnterBackground.......");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_timer_if_waiting_time_return_trip" object:@"stop_timer_if_waiting_time_return_trip" userInfo:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@"------------->applicationWillEnterForeground.......");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart_timer_if_waiting_time_return_trip" object:@"restart_timer_if_waiting_time_return_trip" userInfo:nil];
    [self timerFired];
}

#pragma mark - Show views

- (void)configMenuSideWithOrder:(OOrderAvailable*)curOrder
{
    if (curOrder==nil)
    {
        [OOrderAvailable deleteAllOrder];
        VCLogin *login = VCUSER(VCLogin);
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        self.window.rootViewController = nav;
    }
    else
    {
        VCOrderAssign *order = VCORDER(VCOrderAssign);
        order.currentOrder = curOrder;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:order];
        self.window.rootViewController = nav;
    }
}

-(void)addLeftPanelwithOrderFromNotify:(OOrderAvailable*)curOrder
{
    self.jaSide = [[JASidePanelController alloc]init];
    
    VCAvailableOrder *order = VCAVAILABEL(VCAvailableOrder);
    order.tempOrder = curOrder;
    APPSHARE.fwNotify = @"forward";
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:order];
    self.jaSide.centerPanel = nav;
    
    VCMenu *menu = VCSETTING(VCMenu);
    self.jaSide.leftPanel = menu;
    self.state = sList;
    
    self.window.rootViewController = self.jaSide;
}

-(void)addLeftPanelwithOrder:(OOrderAvailable*)curOrder
{
    self.jaSide = [[JASidePanelController alloc]init];
    
    if (curOrder == nil)
    {
        if (APPSHARE.userLogin.is_approved)
        {
            [OOrderAvailable deleteAllOrder];
            VCAvailableOrder *order = VCAVAILABEL(VCAvailableOrder);
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:order];
            self.jaSide.centerPanel = nav;
        }
        else
        {
            [OOrderAvailable deleteAllOrder];
            VCPermission *vc = VCUSER(VCPermission);
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            self.jaSide.centerPanel = nav;
        }
    }
    else
    {
        APPSHARE.isWork = YES;
//        if (self.userLogin.is_bulk)
//        {
//            VCOrderBulkAssign *order = VCORDERBULK(VCOrderBulkAssign);
//            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:order];
//            self.jaSide.centerPanel = nav;
//        }
//        else
//        {
            VCOrderAssign *order = VCORDER(VCOrderAssign);
            order.currentOrder = curOrder;
            [[WatchManager shared] sendStatusOrder:curOrder];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:order];
            self.jaSide.centerPanel = nav;
//        }
    }
    
    VCMenu *menu = VCSETTING(VCMenu);
    self.jaSide.leftPanel = menu;
    self.state = sList;
    
    self.window.rootViewController = self.jaSide;
}

- (void)addLeftPanelwithBulkOrder:(OBulk *)curOrder
{
    self.jaSide = [[JASidePanelController alloc]init];
    
    VCOrderBulkAssign *order = VCORDERBULK(VCOrderBulkAssign);
    order.currentOrder = curOrder;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:order];
    self.jaSide.centerPanel = nav;
    
    VCMenu *menu = VCSETTING(VCMenu);
    self.jaSide.leftPanel = menu;
    self.state = sList;
    
    self.window.rootViewController = self.jaSide;
}

- (void)showVerifyPhone
{
    VCVerifyPhone *verify = VCUSER(VCVerifyPhone);
    verify.strPhone = self.userLogin.phone;
    verify.isNeedConfigMenuSide = YES;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:verify];
    self.window.rootViewController = nav;
}

-(void)addLeftPanelOnly
{
    self.jaSide = [[JASidePanelController alloc]init];
    VCMenu *menu = VCSETTING(VCMenu);
    self.jaSide.leftPanel = menu;
}

- (void)showSplash
{
    VCSplash *splash = VCSETTING(VCSplash);
    self.window.rootViewController = splash;
}


#pragma mark - Block

- (void)showBlock{
    RESIGN_KEYBOARD
    VCBlockAccount *block = VCUSER(VCBlockAccount);
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:block];
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)showLogin{
    RESIGN_KEYBOARD
    VCLogin *login = VCUSER(VCLogin);
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

-(void)checkActiveOrder:(BOOL)value
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    APPSHARE.userLogin.activeOrder = value;
    [realm commitWriteTransaction];
    RELOAD_MENU_LEFT
}

-(void)clearBulkOrder
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    APPSHARE.userLogin.proBasket = NULL;
    [realm commitWriteTransaction];
    RELOAD_MENU_LEFT
}

#pragma mark - Watch App

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message{
    if (message)
    {
        DLog(@"message = %@",message);
        NSString *action = [message objectForKey:@"action"];
        if ([action isEqualToString:@"take"])
        {
            [HServiceAPI acceptOrder:[message objectForKey:@"order"] hander:^(NSDictionary *results, NSError *error)
             {
                 if (!error)
                 {
                     [APPSHARE checkActiveOrder:YES];
                     [HServiceAPI getCurrentActiveOrder:^(NSArray *results, NSError *error)
                      {
                          if (!error)
                          {
                              RELOAD_MENU_LEFT
                              OOrderAvailable *o = results[0];
                              [APPSHARE addLeftPanelwithOrder:o];
                              [OOrderAvailable saveOrder:o];
                          }
                      }];
                 }
             }];
        }
        else if ([action isEqualToString:@"call"])
        {
            [Util callTo:[message objectForKey:@"phone"]];
        }
        else if ([action isEqualToString:@"next"])
        {
            [HServiceAPI onCloseOrder:^(BOOL finish, NSError *error)
             {
                 if (!error)
                 {
                     [APPSHARE checkActiveOrder:NO];
                     [OOrderAvailable deleteAllOrder];
                     [[WatchManager shared] completeOrder];
                     [APPSHARE addLeftPanelwithOrder:nil];
                     RELOAD_MENU_LEFT
                 }
             }];
        }
        else if ([action isEqualToString:@"checkOrder"])
        {
            if (self.userLogin==nil) {
                NSDictionary* message = @{@"action":@"nonLogin"};
                
                [[WatchManager shared] sendMessage:message];
            }else{
                
                NSDictionary* message = @{@"action":@"login",
                                          @"data":@"",
                                          @"status":@"1"
                                          };
                
                [[WatchManager shared] sendMessage:message];
                if ([OBulk getCurrentOrder]!=nil) {
                    //co bulk order
                }else if ([OOrderAvailable getCurrentOrder]){
                    //co order
                    [[WatchManager shared] sendStatusOrder:[OOrderAvailable getCurrentOrder]];
                }else{
                    //ko co order nao ca
                    
                    [[WatchManager shared] getOrderAvailable];
                }
            }
        }
    }
}

- (void)showFromNotification:(NSString *)oid
{
    [HServiceAPI getDetailOrderWithID:oid hander:^(NSDictionary *results, NSError *error)
     {
         if (results!=nil)
         {
             if ([[results stringForKey:@"state"]isEqualToString:@"CANCELLED"])
             {
                 NSString *msg;
                 if ([[results stringForKey:@"sender_cancel_reason"]isEqualToString:@"ADMIN_CANCELLED"])
                 {
                     NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[[results stringForKey:@"sender_cancel_note"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                           NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                                                                      documentAttributes:nil
                                                                                   error:nil];
                     msg = [attr string];
                 }
                 else
                 {
                     msg = [NSString stringWithFormat:@"Sender has cancelled Order #%@ \n Reason: Sorry, I have changed my mind !",oid];
                 }
                 [APPSHARE checkActiveOrder:NO];
                 [OOrderAvailable deleteAllOrder];
                 [APPSHARE addLeftPanelwithOrder:nil];
                 [UIAlertView showWithTitle:@"Notice" message:msg handler:nil];
             }
             else
             {
                 if (APPSHARE.userLogin)
                 {
                     self.currentOrder = [OOrderAvailable convertToObject:results];
                     [APPSHARE addLeftPanelwithOrderFromNotify:self.currentOrder];
                 }
             }
         }
         else
         {
             
         }
    }];
}

#pragma mark - NetWork
-(void)checkNetwork{
    //@"https://app.zap.delivery:443"
    NSString *host = [RootURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    host = [host stringByReplacingOccurrencesOfString:@":443" withString:@""];
    
    Reachability *reachability = [Reachability reachabilityWithHostname:host];
    
    // Start Monitoring
    [reachability startNotifier];
}



@end
