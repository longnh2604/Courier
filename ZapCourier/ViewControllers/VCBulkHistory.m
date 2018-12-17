//
//  VCBulkHistory.m
//  ZapCourier
//
//  Created by Long Nguyen on 4/1/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCBulkHistory.h"
#import "TabView.h"
#import "AvailableCell.h"
#import "VCOrderAssign.h"
#import "VCOrderBulkAssign.h"

@interface VCBulkHistory ()<TabViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *arSingle;
    NSMutableArray *arBulk;
    
    BOOL isSingleFull;
    int pageSingle;
    
    BOOL isBulkFull;
    int pageBulk;
    
    NSURLSessionDataTask *tack;
}

@property (weak, nonatomic) IBOutlet TabView *vTab;
@property (weak, nonatomic) IBOutlet UIScrollView *scView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTab;
@property (weak, nonatomic) IBOutlet UITableView *tbBulk;
@property (weak, nonatomic) IBOutlet UITableView *tbSingle;
@property (weak, nonatomic) IBOutlet UIView *vContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthContentSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthTbBulk;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthTbSingle;


@end

@implementation VCBulkHistory

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
    self.title = @"Order history";
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
}
- (void)configSingleTable{
    [self.tbSingle addPullToRefreshWithActionHandler:^{
        [self.tbSingle removeNoOrdersView];
        isSingleFull = NO;
        pageSingle = 1;
        
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
        
    }];
    
    [self.tbSingle addInfiniteScrollingWithActionHandler:^{
        if (!isSingleFull && self.tbSingle.pullToRefreshView.state != SVPullToRefreshStateLoading && arSingle.count>0)
        {
            pageSingle++;
            [self getOrder];
        }
        else
        {
            [self.tbSingle.infiniteScrollingView stopAnimating];
        }
    }];
    [self.tbSingle showNoCompletedOrdersView];
}
- (void)configBulkTable{
    [self.tbBulk addPullToRefreshWithActionHandler:^{
        [self.tbBulk removeNoOrdersView];
        isBulkFull = NO;
        pageBulk = 1;
        
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
        
    }];
    
    [self.tbBulk addInfiniteScrollingWithActionHandler:^{
        if (!isBulkFull && self.tbBulk.pullToRefreshView.state != SVPullToRefreshStateLoading && arBulk.count>5)
        {
            pageBulk++;
            [self getBulkOrder];
        }
        else
        {
            [self.tbBulk.infiniteScrollingView stopAnimating];
        }
    }];
    [self.tbBulk showNoCompletedOrdersView];
}


#pragma mark - FUNCTIONS

- (void)getOrder{
    [tack cancel];
    tack = [HServiceAPI getHistoryWithPage:[NSString stringWithFormat:@"%d",pageSingle] handler:^(NSArray *results,NSString *urlNextPage, NSError *error)
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
                     [self.tbSingle showNoCompletedOrdersView];
                 }
             }
         }
         if (![error.localizedDescription isEqualToString:@"cancelled"]) {
             if (arSingle.count==0 && results.count==0) {
                 [self.tbSingle showNoCompletedOrdersView];
             }
         }
         
         [self.tbSingle.pullToRefreshView stopAnimating];
         [self.tbSingle.infiniteScrollingView stopAnimating];

     }];
}

- (void)getBulkOrder{
    [tack cancel];
    tack = [HServiceAPI getHistoryBulkOrderWithPage:[NSString stringWithFormat:@"%d",pageBulk] handler:^(NSArray *results,NSString *urlNextPage, NSError *error) {
        if (error) DLog(@"error = %@",error.localizedDescription);
        if (urlNextPage.length==0) isBulkFull = YES;
        if (results.count>0)
        {
            [self insertMultiRows:results isBulk:YES];
        }
        else
        {
            if(pageBulk>1){
                pageBulk--;
            }else{
                pageBulk = 1;
            }
            
            if (![error.localizedDescription isEqualToString:@"cancelled"]) {
                if (arBulk.count==0 && results.count==0) {
                    [self.tbBulk showNoCompletedOrdersView];
                }
            }
        }
        if (![error.localizedDescription isEqualToString:@"cancelled"]) {
            if (arBulk.count==0 && results.count==0) {
                [self.tbBulk showNoCompletedOrdersView];
            }
        }
        
        [self.tbBulk.pullToRefreshView stopAnimating];
        [self.tbBulk.infiniteScrollingView stopAnimating];
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
            [self.tbSingle beginUpdates];
            [self.tbSingle insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tbSingle endUpdates];
        }
    }
    
}

#pragma mark - ACTIONS

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
        [cell configCellBulk:b showState:YES];
    }else{
        OOrderAvailable *o = arSingle[indexPath.row];
        [cell configCell:o showState:YES];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tbBulk){
        
        if (arBulk.count>indexPath.row) {
            VCOrderBulkAssign *bulk = VCORDERBULK(VCOrderBulkAssign);
            bulk.isFromHistory = YES;
            bulk.currentOrder = arBulk[indexPath.row];
            [self.navigationController pushViewController:bulk animated:YES];
        }
    }else{
        
        if (arSingle.count>indexPath.row) {
            VCOrderAssign *order = VCORDER(VCOrderAssign);
            order.currentOrder = arSingle[indexPath.row];
            order.isFromHistory = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
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

@end
