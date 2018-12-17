//
//  VCListCard.m
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCListCard.h"
#import "CardCell.h"
#import "VCEditCard.h"
#import "VCNewCard.h"

@interface VCListCard ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    NSIndexPath *selectedIdx;
}

@property (nonatomic, weak) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightButton;
@property (weak, nonatomic) IBOutlet UIView *vButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableView;


@end

@implementation VCListCard

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isChooseCard==YES) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(selectedSkipButton:)];
        self.navigationItem.leftBarButtonItem = item;
        self.vButton.hidden = YES;
        self.bottomTableView.constant = 0;
    }else{
        self.vButton.hidden = NO;
        self.bottomTableView.constant = 70;
    }
    self.title = @"List cards";
    [self.tbView reloadData];
}

#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

- (void)selectedRow:(NSIndexPath*)idx{
    selectedIdx = idx;
    UIActionSheet *act = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete card" otherButtonTitles:@"Set primary card",@"Edit expire date", nil];
    [act showInView:self.view];
}

#pragma mark - ACTIONS

- (void)selectedSkipButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectedAddNewCardButton:(id)sender {
    VCNewCard *new = VCSETTING(VCNewCard);
    [self.navigationController pushViewController:new animated:YES];
}
#pragma mark - DELEGATES


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return APPSHARE.userLogin.arPayment.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell"];
    if (!cell) {
        cell = [[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardCell"];
    }
    OPayment *p = APPSHARE.userLogin.arPayment[indexPath.row];
    
    cell.lbMask.text = p.maskedNumber;
    cell.lbExp.text = [NSString stringWithFormat:@"%@/%@",p.expirationMonth,p.expirationYear];
    [cell.imvPhoto.image setIconForCard:p.cardType];
    if ([p.cardDefault isEqualToString:@"1"]){
        cell.lbPrimary.hidden = NO;
    }else{
        cell.lbPrimary.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<APPSHARE.userLogin.arPayment.count) {
        if (self.isChooseCard) {
            OPayment *p = APPSHARE.userLogin.arPayment[indexPath.row];
            [self.delegate choosedCard:p];
            [self selectedSkipButton:nil];
        }else{
            [self selectedRow:indexPath];
        }
    }
}


//MARK: - ACTIONSHEET

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        DLog(@"Delete");
        [UIAlertView showConfirmationDialogWithTitle:@"Delete this card?" message:@"Are you sure?" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==0) {
                DLog(@"Cancel");
            }else if (buttonIndex==1){
                DLog(@"OK");
                OPayment *p = APPSHARE.userLogin.arPayment[selectedIdx.row];
                [HServiceAPI deleteCardWithToken:p.token handler:^(BOOL finish, NSError *error) {
                    if (finish) {
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        [realm beginWriteTransaction];
                        [APPSHARE.userLogin.arPayment removeObjectAtIndex:selectedIdx.row];
                        [realm commitWriteTransaction];
                        [self.tbView reloadData];
                    }
                }];
            }
        }];
    }else if (buttonIndex==1) {
        DLog(@"set primary card");
        OPayment *p = APPSHARE.userLogin.arPayment[selectedIdx.row];
        [HServiceAPI makePrimaryCardWithToken:p.token handler:^(BOOL finish, NSError *error) {
            if (finish) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                for (OPayment *pm in APPSHARE.userLogin.arPayment) {
                    if (![pm isEqualToObject:p]) {
                        pm.cardDefault = @"0";
                    }
                }
                p.cardDefault = @"1";
                
                [realm commitWriteTransaction];
                [self.tbView reloadData];
            }
        }];
    }else if (buttonIndex==2) {
        DLog(@"Edit");
        VCEditCard *edit = VCSETTING(VCEditCard);
        edit.cardIdx = (int)selectedIdx.row;
        [self.navigationController pushViewController:edit animated:YES];
    }else if (buttonIndex==3) {
        DLog(@"cancel");
    }
}

@end
