//
//  VCOrderAvailable.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCOrderAvailable.h"
#import "OrderAvailableCell.h"
#import "OOrderAvailable.h"
#import "DefaultButton.h"
#import "VCMenu.h"
#import "VCOrderAvailableDetail.h"
#import "VCOrderBulkAssign.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface VCOrderAvailable ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,WCSessionDelegate>
{
    NSMutableArray *arOrders;
    BOOL isFull;
    int page;
    NSTimer *timerRefresh;
    NSString *filePath;
    NSString *json2Watch;
    BOOL allowRefresh;
}

@property (nonatomic, weak) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet UILabel *lbOfflineTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbOfflineDescription;
@property (weak, nonatomic) IBOutlet DefaultButton *btnActiveWorking;
@property (weak, nonatomic) IBOutlet UIView *viewOffline;
@property (weak, nonatomic) IBOutlet UIImageView *imvNoData;
@property (weak, nonatomic) IBOutlet UIView *viewNoData;

@end

@implementation VCOrderAvailable

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    self.title = @"Available Orders";
    
    [self updateLocation:APPSHARE.arrUserLocation];
    self.imvNoData.hidden = YES;
    self.viewNoData.hidden = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myWorkStatus = [prefs stringForKey:@"workstatus"];
    filePath = [prefs stringForKey:@"plistPath"];

    [self setLayout];
    
    if (APPSHARE.isWork || [myWorkStatus isEqualToString:@"work"])
    {
        [self onWorkStatus];
    }
    else
    {
        [self onOfflineStatus];
    }
    
    [self.btnActiveWorking addTarget:self action:@selector(selectedActive) forControlEvents:UIControlEventTouchUpInside];
    [timerRefresh invalidate];
    timerRefresh = nil;
    timerRefresh = [NSTimer scheduledTimerWithTimeInterval:currentOrderRefreshInterval repeats:YES block:^{
        [self refreshListOrder];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkStatus) name:@"workStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOfflineStatus) name:@"offlineStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reUpdateLocation) name:@"reupdateLocation" object:nil];
}

-(void)onStopUpdate
{
    [timerRefresh invalidate];
    timerRefresh = nil;
}

- (void)updateLocation:(NSMutableArray *)data
{
    [HServiceAPI updateCurrentPosition:data success:^{
    }];
}

- (void)onWorkStatus
{
    self.tbView.hidden = NO;
    self.viewOffline.hidden = YES;
    
    APPSHARE.isWork = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"work" forKey:@"workstatus"];
    [defaults synchronize];
    
    [[APNSManager shared] registerAPNS];
    [self sendDataToWatch:@""];
}

- (void)reUpdateLocation
{
    [self updateLocation:APPSHARE.arrUserLocation];
}

- (void)onOfflineStatus
{
    self.tbView.hidden = YES;
    self.viewOffline.hidden = NO;
   
    APPSHARE.isWork = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"offline" forKey:@"workstatus"];
    [defaults synchronize];
    
    self.viewNoData.hidden = YES;
    self.imvNoData.hidden = YES;
    [[APNSManager shared] unregisterAPNS];
    [self sendDataToWatch:@""];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tbView triggerPullToRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderFromNotification) name:@"reloadOrderAvailable" object:nil];
    
    if ([APPSHARE.fwNotify isEqualToString:@"forward"])
    {
        OOrderAvailable *o = self.tempOrder;
        
        VCOrderAvailableDetail *order = VCORDER(VCOrderAvailableDetail);
        order.currentOrder = o;
        [self.navigationController pushViewController:order animated:YES];
        APPSHARE.fwNotify = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timerRefresh invalidate];
    timerRefresh = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadOrderAvailable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reupdateLocation" object:nil];
}
#pragma mark - LAYOUT

- (void)setLayout
{
    [self.tbView addPullToRefreshWithActionHandler:^{
        isFull = NO;
        page = 1;
        
        if (arOrders==nil)
        {
            arOrders = [NSMutableArray array];
        }
        else
        {
            [arOrders removeAllObjects];
        }
        
        [self.tbView reloadData];
        [self.tbView.infiniteScrollingView stopAnimating];
        [self getOrder];
    }];
    
    [self.tbView addInfiniteScrollingWithActionHandler:^{
        if (!isFull)
        {
            page++;
            [self getOrder];
        }
        else
        {
            [self.tbView.infiniteScrollingView stopAnimating];
        }
    }];
}

#pragma mark - FUNCTIONS

- (void)getOrderFromNotification
{
    if (self.tbView.pullToRefreshView.state == SVPullToRefreshStateStopped)
    {
        [self.tbView triggerPullToRefresh];
        [[WatchManager shared] alertNewOrder];
    }
}

- (void)refreshListOrder
{
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        //...Location service is enabled
    }
    else
    {
        if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0)
        {
            UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location service" message:@"You can enable access in Settings->Privacy->Location->Location Services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [curr1 show];
        }
        else
        {
            UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location service" message:@"You can enable access in Settings->Privacy->Location->Location Services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Settings", nil];
            curr2.tag=121;
            [curr2 show];
        }
    }
    
    if (self.tbView.pullToRefreshView.state == SVPullToRefreshStateStopped)
    {
        [self.tbView triggerPullToRefresh];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%ld",(long)buttonIndex);
    
    if (alertView.tag == 121 && buttonIndex == 1)
    {
        //code for opening settings app in iOS 8
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)getOrder
{
    [HServiceAPI getOrderAvailableWithPage:[NSString stringWithFormat:@"%d",page] handler:^(NSArray *results, NSString *urlNextPage, NSError *error)
     {
         if(error)
         {
             NSLog(@"in page %d",page);
             page = 0;
             [self errorHandler:error];
             [arOrders removeAllObjects];
             [self.tbView reloadData];
             
             [self.tbView.pullToRefreshView stopAnimating];
             [self.tbView.infiniteScrollingView stopAnimating];
             
             return;
         }
         
         if (results.count>0)
         {
             self.imvNoData.hidden = YES;
             self.viewNoData.hidden = YES;
             if (results.count<historyPageSize)
             {
                 isFull = YES;
             }
             
             [self insertMultiRows:results];
         }
         else
         {
             if (arOrders.count==0 && error==nil)
             {
                 page--;
                 isFull = YES;
                 
                 if (APPSHARE.isWork)
                 {
                     self.imvNoData.hidden = NO;
                     self.viewNoData.hidden = NO;
                 }
             }
         }
         
         [self.tbView reloadData];
         [self.tbView.pullToRefreshView stopAnimating];
         [self.tbView.infiniteScrollingView stopAnimating];
         
         [self createEditableCopyOfIfNeeded];
         [self getDataPlist];
         [self sendDataToWatch:json2Watch];
     }];
}

- (void)sendDataToWatch:(NSString *)data
{
//    NSString * booleanString = [NSString stringWithFormat:@"%d",APPSHARE.isWork];
    
//    [[WatchManager shared] sendDataToWatch:data withUserStatus:booleanString];
}

- (NSString *)boolValueToString:(BOOL)theBool {
    if (theBool == 0)
        return @"NO"; // can change to No, NOOOOO, etc
    else
        return @"YES"; // can change to YEAH, Yes, YESSSSS etc
}

- (void)createEditableCopyOfIfNeeded
{
    NSMutableDictionary *reply = [NSMutableDictionary new];
    NSAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:@"My String"];
    reply[@"otherKey"] = [NSKeyedArchiver archivedDataWithRootObject: myString];
    
    // First, test for existence.
    BOOL success;
    
    NSURL *fileM = [[NSFileManager defaultManager]containerURLForSecurityApplicationGroupIdentifier:@"group.delivery.zap.courier.sharedContainer"];
    NSString *fileMstring = [fileM absoluteString];
    NSString *newStr = [fileMstring substringFromIndex:7];
    
    NSLog(@"%@",fileM);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

    NSString *writablePath = [newStr stringByAppendingPathComponent:@"orders.plist"];
    success = [fileManager fileExistsAtPath:writablePath];
    
    if (success)
        return;
    
    // The writable file does not exist, so copy from the bundle to the appropriate location.
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"orders.plist"];
    success = [fileManager copyItemAtPath:defaultPath toPath:writablePath error:&error];
    if (!success)
        NSAssert1(0, @"Failed to create writable file with message '%@'.", [error localizedDescription]);
}

- (void)getDataPlist
{
    NSURL *fileM = [[NSFileManager defaultManager]containerURLForSecurityApplicationGroupIdentifier:@"group.delivery.zap.courier.sharedContainer"];
    NSString *fileMstring = [fileM absoluteString];
    filePath = [fileMstring substringFromIndex:7];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:filePath forKey:@"plistPath"];
    [defaults synchronize];
    
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"orders.plist"];
    
    NSMutableArray *tableData = [NSMutableArray arrayWithContentsOfFile:plistPath];
    
    if (nil == tableData)
    {
        tableData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    else {
    }
    
    [tableData removeAllObjects];
    for (NSInteger i = 0; i < [arOrders count]; i++)
    {
        NSMutableDictionary *array = [[NSMutableDictionary alloc]init];
        
        OOrderAvailable *order = arOrders[i];
        NSString *returnCheck = [NSString stringWithFormat:@"%d",order.isReturnTrip];
        
        [array setObject:order.oid forKey:@"orderId"];
        [array setObject:order.price forKey:@"orderPrice"];
        [array setObject:order.pickupAddress forKey:@"orderPickup"];
        [array setObject:order.dropoffAddress forKey:@"orderDropoff"];
        [array setObject:returnCheck forKey:@"orderReturn"];
        
        [tableData addObject:array];
        [tableData writeToFile:plistPath atomically: TRUE];
    }
    NSData* data = [ NSJSONSerialization dataWithJSONObject:tableData options:NSJSONWritingPrettyPrinted error:nil ];
    json2Watch = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(void)insertMultiRows:(NSArray*)dataToAdd
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger currentCount = arOrders.count;
    for (int i = 0; i < dataToAdd.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
    }
    // do the insertion
    [arOrders addObjectsFromArray:dataToAdd];
    
    // tell the table view to update (at all of the inserted index paths)
    if (indexPaths.count>0){
        [self.tbView beginUpdates];
        [self.tbView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tbView endUpdates];
    }
    
}
#pragma mark - ACTIONS

#pragma mark - DELEGATES

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"arrOrder %lu",(unsigned long)arOrders.count);
    return arOrders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 146;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderAvailableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderAvailableCell"];
    if (!cell) {
        cell = [[OrderAvailableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OrderAvailableCell"];
    }
    [cell configCell:arOrders[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderAvailableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.viewLeft.backgroundColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
    cell.viewRight.backgroundColor = [UIColor colorWithRed:209/255.0 green:239/255.0 blue:255/255.0 alpha:1];
    
    OOrderAvailable *o = arOrders[indexPath.row];
    
    VCOrderAvailableDetail *order = VCORDER(VCOrderAvailableDetail);
    order.currentOrder = o;
    [self.navigationController pushViewController:order animated:YES];
    
//    VCOrderBulkAssign *order = VCORDERBULK(VCOrderBulkAssign);
//    order.currentOrder = o;
//    [self.navigationController pushViewController:order animated:YES];

}

- (void)selectedActive
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"work" forKey:@"workstatus"];
    [defaults synchronize];
    
    [[APNSManager shared] registerAPNS];
    
    WORKING_MODE;
    APPSHARE.isWork = YES;
    self.tbView.hidden = NO;
    self.viewOffline.hidden = YES;
    [self sendDataToWatch:@""];
    
    [self.tbView triggerPullToRefresh];
}

@end
