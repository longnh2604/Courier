//
//  VCMyRewards.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCMyRewards.h"
#import "MyRewardsCell.h"

@interface VCMyRewards ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arOrders;
    BOOL isFull;
    int page;
}

@property (nonatomic, weak) IBOutlet UITableView *tbView;

@end

@implementation VCMyRewards

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"My Rewards";
    [self setLayout];
    self.tbView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tbView.separatorColor = [UIColor clearColor];
}
- (void)viewDidAppear:(BOOL)animated {
    [self.tbView triggerPullToRefresh];
}

#pragma mark - LAYOUT

- (void)setLayout{
    [self.tbView addPullToRefreshWithActionHandler:^{
        isFull = NO;
        page = 1;
        
        if (arOrders==nil) {
            arOrders = [NSMutableArray array];
        }else{
            [arOrders removeAllObjects];
        }
        
        [self.tbView reloadData];
        [self getRewards];
    }];
    
    [self.tbView addInfiniteScrollingWithActionHandler:^{
        if (!isFull) {
            page++;
            [self getRewards];
        }else{
            [self.tbView.infiniteScrollingView stopAnimating];
        }
    }];
}

#pragma mark - FUNCTIONS

- (void)getRewards
{
    [HServiceAPI getMyRewardsWithPage:[NSString stringWithFormat:@"%d",page] handler:^(NSArray *results,NSString *urlNextPage, NSError *error)
     {
         if (urlNextPage.length==0) isFull = YES;
        if (results.count>0)
        {
            [self insertMultiRows:results];
        }
        else
        {
            if (page>1) {
                page--;
            }else{
                page = 1;
            }
        }
        
        [self.tbView.pullToRefreshView stopAnimating];
        [self.tbView.infiniteScrollingView stopAnimating];
         
         if (error) DLog(@"error = %@",error.localizedDescription);
    }];
}
-(void)insertMultiRows:(NSArray*)dataToAdd{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger currentCount = arOrders.count+3;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arOrders.count+3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyRewardsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyRewardsCell"];
    if (!cell) {
        cell = [[MyRewardsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyRewardsCell"];
    }
    
    if (indexPath.row == 0)
    {
        cell.lbTitle.text = @"Next Payment";
        cell.lbPrice.text = APPSHARE.userLogin.poAvailable;
        cell.lbTime.hidden = YES;
    }
    else if (indexPath.row == 1)
    {
        cell.lbTitle.text = @"On Hold";
        cell.lbTime.hidden = YES;
        cell.viewLeft.backgroundColor = [UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1];
        cell.viewRight.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        cell.lbPrice.text = APPSHARE.userLogin.poHold;
    }
    else if (indexPath.row == 2)
    {
        cell.lbTitle.text = @"Total Paid";
        cell.lbTime.hidden = YES;
        cell.viewLeft.backgroundColor = [UIColor colorWithRed:234/255.0 green:30/255.0 blue:99/255.0 alpha:1];
        cell.viewRight.backgroundColor = [UIColor colorWithRed:251/255.0 green:228/255.0 blue:236/255.0 alpha:1];
        cell.lbPrice.text = APPSHARE.userLogin.poPaid;
    }
    else
    {
        cell.lbTitle.text = @"Processing";
        [cell configCellRewards:arOrders[0]];
    }
    
//    if (indexPath.row == self.newCarArray.count-1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
