//
//  VCHistory.m
//  Delivery
//
//  Created by Long Nguyen on 1/6/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCHistory.h"
#import "HistoryCell.h"
#import "VCOrderAssign.h"

@interface VCHistory ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arOrders;
    BOOL isFull;
    int page;
}

@property (nonatomic, weak) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet UIView *viewNodata;
@property (weak, nonatomic) IBOutlet UIImageView *iconNodata;

@end

@implementation VCHistory


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Order history";
    [self setLayout];
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
        [self getOrder];
    }];
    
    [self.tbView addInfiniteScrollingWithActionHandler:^{
        if (!isFull) {
            page++;
            [self getOrder];
        }else{
            [self.tbView.infiniteScrollingView stopAnimating];
        }
    }];
}

#pragma mark - FUNCTIONS

- (void)getOrder{
    [HServiceAPI getHistoryWithPage:[NSString stringWithFormat:@"%d",page] handler:^(NSArray *results,NSString *urlNext, NSError *error)
     {
        if (results.count>0)
        {
            self.viewNodata.hidden = YES;
            self.iconNodata.hidden = YES;
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
            
                self.viewNodata.hidden = NO;
                self.iconNodata.hidden = NO;
            }
        }
        
        [self.tbView.pullToRefreshView stopAnimating];
        [self.tbView.infiniteScrollingView stopAnimating];
    }];
}
-(void)insertMultiRows:(NSArray*)dataToAdd{
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arOrders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 146;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if (!cell) {
        cell = [[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryCell"];
    }
    [cell configCell:arOrders[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OOrderAvailable *o = arOrders[indexPath.row];
    
    VCOrderAssign *order = VCORDER(VCOrderAssign);
    order.currentOrder = o;
    order.isFromHistory = YES;
    [self.navigationController pushViewController:order animated:YES];
}

@end
