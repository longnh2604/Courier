//
//  VCAvailableOrder.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCAvailableOrder.h"
#import "AvailableCell.h"
#import "TabView.h"
#import "VCAcceptJobs.h"
#import "VCOrderAvailableDetail.h"

@interface VCAvailableOrder ()<TabViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    __weak IBOutlet UIView *vOffline;
    
    NSMutableArray *arSingle;
    NSMutableArray *arBulk;
    
    int pageSingle;
    BOOL isSingleFull;
    
    int pageBulk;
    BOOL isBulkFull;
    
    NSURLSessionDataTask *tack;
    NSTimer *timerRefresh;
    UIAlertView *alertLocation;
}


@property (weak, nonatomic) IBOutlet UIScrollView *scView;
@property (weak, nonatomic) IBOutlet TabView *vTab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTab;
@property (weak, nonatomic) IBOutlet UITableView *tbBulk;
@property (weak, nonatomic) IBOutlet UITableView *tbSingle;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthContentSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthTbBulk;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthTbSingle;


@end

@implementation VCAvailableOrder

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.vTab.delegate = self;
    
    [self setLayout];
    if (APPSHARE.userLogin.is_bulk){
        [self.tbBulk triggerPullToRefresh];
    }else{
        [self.tbSingle triggerPullToRefresh];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Available Orders";
    [self showWorkingMoke];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadOrderAvailable" object:nil];
    [timerRefresh invalidate];
    timerRefresh = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    
    if ([APPSHARE.fwNotify isEqualToString:@"forward"])
    {
        OOrderAvailable *o = self.tempOrder;
        
        VCOrderAvailableDetail *order = VCORDER(VCOrderAvailableDetail);
        order.currentOrder = o;
        [self.navigationController pushViewController:order animated:YES];
        APPSHARE.fwNotify = nil;
    }
}
#pragma mark - LAYOUT

- (void)setLayout{
    
    //setup tableview & tab
    if (APPSHARE.userLogin.is_bulk){
        self.widthContentSize.constant = SCREEN_WIDTH*2;
        [self configBulkTable];
        self.scView.scrollEnabled = YES;
        self.heightTab.constant = 50;
        self.widthTbBulk.constant = SCREEN_WIDTH;
        self.widthTbSingle.constant = SCREEN_WIDTH;
    }else{
        self.widthContentSize.constant = SCREEN_WIDTH;
        self.heightTab.constant = 0;
        self.scView.scrollEnabled = NO;
        self.widthTbBulk.constant = 0;
        self.widthTbSingle.constant = SCREEN_WIDTH;
    }
    [self configSingleTable];
    
    //setup notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWorkStatus) name:@"workStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOfflineStatus) name:@"offlineStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderFromNotification) name:@"reloadOrderAvailable" object:nil];
    
    
    //update constraints
    [self.view updateConstraints];
}

- (void)showWorkingMoke{
    //setup work status
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *myWorkStatus = [prefs stringForKey:@"workstatus"];
    
    if (APPSHARE.isWork || [myWorkStatus isEqualToString:@"work"]){
        [self onWorkStatus];
    }else{
        [self onOfflineStatus];
    }
    vOffline.hidden = APPSHARE.isWork;
}

- (void)configSingleTable{
    [self.tbSingle addPullToRefreshWithActionHandler:^{
        if (APPSHARE.isWork) {
            [self.tbSingle removeNoOrdersView];
            pageSingle = 1;
            isSingleFull = NO;
            
            if (arSingle==nil)
            {
                arSingle = [NSMutableArray array];
            }
            else
            {
                [arSingle removeAllObjects];
            }
            [self.tbSingle reloadData];
            [self.tbSingle.infiniteScrollingView stopAnimating];
            [self getOrder];
        }
        
    }];
    
    [self.tbSingle addInfiniteScrollingWithActionHandler:^{
        if (APPSHARE.isWork) {
            if (!isSingleFull && self.tbSingle.pullToRefreshView.state != SVPullToRefreshStateLoading)
            {
                pageSingle++;
                [self getOrder];
            }
            else
            {
                [self.tbSingle.infiniteScrollingView stopAnimating];
            }
        }
    }];
}
- (void)configBulkTable{
    [self.tbBulk addPullToRefreshWithActionHandler:^{
        if (APPSHARE.isWork) {
            [self.tbBulk removeNoOrdersView];
            pageBulk = 1;
            isBulkFull = NO;
            
            if (arBulk==nil)
            {
                arBulk = [NSMutableArray array];
            }
            else
            {
                [arBulk removeAllObjects];
            }
            
            [self.tbBulk reloadData];
            [self.tbBulk.infiniteScrollingView stopAnimating];
            [self getBulkOrder];
        }
        
    }];
    
    [self.tbBulk addInfiniteScrollingWithActionHandler:^{
        if (APPSHARE.isWork) {
            if (!isBulkFull && self.tbBulk.pullToRefreshView.state != SVPullToRefreshStateLoading)
            {
                pageBulk++;
                [self getBulkOrder];
            }
            else
            {
                [self.tbBulk.infiniteScrollingView stopAnimating];
            }
        }
    }];
}

#pragma mark - FUNCTIONS

- (void)getOrderFromNotification
{
    //need refresh
    isSingleFull = NO;
    isBulkFull = NO;
    pageBulk = 1;
    pageSingle = 1;
    [arSingle removeAllObjects];
    [arBulk removeAllObjects];
    
    [self refreshOrder];
    
}

- (void)refreshOrder{
    if (!APPSHARE.userLogin.is_bulk) {
        [self.tbSingle triggerPullToRefresh];
    }else{
        if (self.scView.contentOffset.x==SCREEN_WIDTH){
            [self.tbSingle triggerPullToRefresh];
        }else if (self.scView.contentOffset.x==0){
            [self.tbBulk triggerPullToRefresh];
        }
    }
}

//Working mode -> hidden view offline
- (void)onWorkStatus{
    vOffline.hidden = YES;
    APPSHARE.isWork = YES;
    [Util setObject:@"work" forKey:@"workstatus"];
    [self refreshOrder];
    [[APNSManager shared] registerAPNS];
    WORKING_MODE //-> notification to VCMenu
}

//offline mode -> show view offline
- (void)onOfflineStatus{
    vOffline.hidden = NO;
    APPSHARE.isWork = NO;
    [Util setObject:@"offline" forKey:@"workstatus"];
    [[APNSManager shared] unregisterAPNS];
    OFFLINE_MODE //-> notification to VCMenu
}


//get order single
- (void)getOrder{
    [tack cancel];//cancel request trước đó đã chạy nhưng chưa xong
    tack = [HServiceAPI getOrderAvailableWithPage:[NSString stringWithFormat:@"%d",pageSingle] handler:^(NSArray *results, NSString *urlNextPage, NSError *error)
     {
         if (error) DLog(@"error = %@",error.localizedDescription);
         if (urlNextPage.length==0) isSingleFull = YES;
         if (results.count>0)
         {
             
             [self insertMultiRows:results isBulk:NO];
         }
         else
         {
             if (pageSingle>1){
                 pageSingle--;
             }else{
                 pageSingle = 1;
             }
             if (![error.localizedDescription isEqualToString:@"cancelled"]) {
                 if (arSingle.count==0 && results.count==0) {
                     [self.tbSingle showNoOrdersView];
                 }
             }
             [[WatchManager shared] sendDataToWatch:nil withUserStatus:[NSString stringWithFormat:@"%d",APPSHARE.isWork]];
         }
         if (![error.localizedDescription isEqualToString:@"cancelled"]) {
             [self.tbSingle.pullToRefreshView stopAnimating];
             [self.tbSingle.infiniteScrollingView stopAnimating];
         }
     }];
}

//get order bulk
- (void)getBulkOrder{
    [tack cancel];
    
    tack = [HServiceAPI getBulkOrderAvailableWithPage:[NSString stringWithFormat:@"%d",pageBulk] handler:^(NSArray *results, NSString *urlNextPage, NSError *error)
     {
         if (error) DLog(@"error = %@",error.localizedDescription);
         if (urlNextPage.length==0) isBulkFull = YES;
         if (results.count>0)
         {
             [self insertMultiRows:results isBulk:YES];
         }
         else
         {
             if (pageBulk>1){
                 pageBulk--;
             }else{
                 pageBulk = 1;
             }
             if (![error.localizedDescription isEqualToString:@"cancelled"])
             {
                 if (arBulk.count==0 && results.count==0) {
                     [self.tbBulk showNoOrdersView];
                 }
             }
         }
         if (![error.localizedDescription isEqualToString:@"cancelled"]) {
             [self.tbBulk.pullToRefreshView stopAnimating];
             [self.tbBulk.infiniteScrollingView stopAnimating];
         }
     }];
}

//insert row to tableview
-(void)insertMultiRows:(NSArray*)dataToAdd isBulk:(BOOL)isBulk{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger currentCount = (isBulk)?arBulk.count:arSingle.count;
    for (int i = 0; i < dataToAdd.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
    }
    if (isBulk) {
        [self.tbBulk removeNoOrdersView];
        [arBulk addObjectsFromArray:dataToAdd];
        if (indexPaths.count>0){
            [self.tbBulk beginUpdates];
            [self.tbBulk insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tbBulk endUpdates];
        }
    }else{
        [self.tbSingle removeNoOrdersView];
        [arSingle addObjectsFromArray:dataToAdd];
        if (indexPaths.count>0){
            [[WatchManager shared] sendDataToWatch:arSingle withUserStatus:[NSString stringWithFormat:@"%d",APPSHARE.isWork]];
            [self.tbSingle beginUpdates];
            [self.tbSingle insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tbSingle endUpdates];
        }
    }
    
}

#pragma mark - ACTIONS

- (IBAction)selectedStartWorkingButton:(id)sender {
    [self onWorkStatus];
}


#pragma mark - DELEGATES

//MARK: - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.tbSingle) {
        return arSingle.count;
    }else{
        return arBulk.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 170;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AvailableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AvailableCell" forIndexPath:indexPath];
    
    if (tableView==self.tbBulk) {
        OBulk *b = arBulk[indexPath.row];
        [cell configCellBulk:b showState:NO];
    }else{
        OOrderAvailable *o = arSingle[indexPath.row];
        [cell configCell:o showState:NO];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == self.tbBulk){
        VCAcceptJobs *accept = VCAVAILABEL(VCAcceptJobs);
        accept.bulkJobs = arBulk[indexPath.row];
        [self.navigationController pushViewController:accept animated:YES];
    }else{
        OOrderAvailable *o = arSingle[indexPath.row];
        
        VCOrderAvailableDetail *order = VCORDER(VCOrderAvailableDetail);
        order.currentOrder = o;
        [self.navigationController pushViewController:order animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    //change background color when user select a row
    AvailableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.vOrder.backgroundColor = UIColorFromRGB(clBlue);
    cell.vInfo.backgroundColor = UIColorFromRGB(0xe1f5fe);
    cell.imvSize.tintColor = UIColorFromRGB(clBlue);
    return YES;
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    //restore to initial background color
    AvailableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.vOrder.backgroundColor = UIColorFromRGB(0xb2b2b2);
    cell.vInfo.backgroundColor = UIColorFromRGB(0xf7f7f7);
    cell.imvSize.tintColor = UIColorFromRGB(clGray2);
}

//MARK: - TabView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y==0 && scrollView==self.scView){
        [self.vTab updateViewWhenScrolling:scrollView.contentOffset];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView==self.scView){
        if (scrollView.contentOffset.x<SCREEN_WIDTH && arBulk.count==0) {
            [self.tbBulk triggerPullToRefresh];
        }else if (scrollView.contentOffset.x>=SCREEN_WIDTH && arSingle.count==0){
            [self.tbSingle triggerPullToRefresh];
        }
    }
}

- (void)tabViewSelectedButtonAtIndex:(int)idx{
    [self.scView scrollRectToVisible:CGRectMake(SCREEN_WIDTH*idx, 0, SCREEN_WIDTH, self.scView.height) animated:YES];
    if (idx==0 && arBulk.count==0) {
        [self.tbBulk triggerPullToRefresh];
    }else if (idx==1 && arSingle.count==0){
        [self.tbSingle triggerPullToRefresh];
    }
}

//MARK: - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 121 && buttonIndex == 1)
    {
        alertLocation = nil;
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
