//
//  VCNewCard.m
//  Delivery
//
//  Created by Long Nguyen on 1/5/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCNewCard.h"
#import "NewCardCell.h"
#import "UseCardCell.h"
#import "DateCardCell.h"
#import "CardIO.h"

@interface VCNewCard ()<UITableViewDataSource,UITableViewDelegate,NewCardDelegate,CardIOPaymentViewControllerDelegate,DateCardDelegate>{
    NSString *cardNumber;
    NSString *cardMonth;
    NSString *cardYear;
    NSString *cardCVV;
}

@property (weak, nonatomic) IBOutlet UITableView *tbView;


@end

@implementation VCNewCard

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Add new card";
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
    if (self.isFromPresent) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(selectedSkipButton:)];
        self.navigationItem.leftBarButtonItem = item;
    }
}
#pragma mark - LAYOUT

#pragma mark - FUNCTIONS

- (BOOL)validateInfo{
    RESIGN_KEYBOARD
    if (cardMonth.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter expiration month" handler:nil];
        return NO;
    }
    if (![Util checkNumbericWithString:cardMonth] || cardMonth.length>2) {
        [UIAlertView showErrorWithMessage:@"Expiration month invalid" handler:nil];
        return NO;
    }
    if (cardMonth.intValue<1 || cardMonth.intValue>12) {
        [UIAlertView showErrorWithMessage:@"Expiration month must be from 1 to 12" handler:nil];
        return NO;
    }
    if (cardYear.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter expiration year" handler:nil];
        return NO;
    }
    if (![Util checkNumbericWithString:cardYear]) {
        [UIAlertView showErrorWithMessage:@"Expiration year invalid. Please take 2 last number of years." handler:nil];
        return NO;
    }
    if (cardYear.length>2) {
        [UIAlertView showErrorWithMessage:@"Expiration year must be 2 characters" handler:nil];
        return NO;
    }
    if (cardCVV.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter CVC/CVV" handler:nil];
        return NO;
    }
    if (cardCVV.length>4) {
        [UIAlertView showErrorWithMessage:@"CVC/CVV must be from 3 to 4 characters" handler:nil];
        return NO;
    }
    if (cardNumber.length<1) {
        [UIAlertView showErrorWithMessage:@"Please enter your card number" handler:nil];
        return NO;
    }
    if (cardNumber.length<minCardNumberLength || cardNumber.length>maxCardNumberLength) {
        [UIAlertView showErrorWithMessage:[NSString stringWithFormat:@"Card number length should be between %d and %d characters",minCardNumberLength,maxCardNumberLength] handler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - ACTIONS

- (void)selectedSkipButton:(UIButton*)button{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectedScanButton:(id)sender {
    
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [self presentViewController:scanViewController animated:YES completion:nil];
}

- (void)selectedUseCardButton:(UIButton*)button{
    if ([self validateInfo]) {
        [HServiceAPI addNewCardWithNumber:cardNumber cvv:cardCVV month:cardMonth year:[NSString stringWithFormat:@"20%@",cardYear] hander:^(NSString *token, NSError *error) {
            if (token!=nil) {
                [HServiceAPI bindCard:token handler:^(NSDictionary *result, NSError *error) {
                    //
                    if (result!=nil) {
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        [realm beginWriteTransaction];
                        OPayment *p = [OPayment convertObject:result];
                        [APPSHARE.userLogin.arPayment addObject:p];
                        [realm commitWriteTransaction];
                        if (self.isFromPresent) {
                            [self.delegate addNewCardDone:p];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }else{
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }
                }];
            }
        }];
    }
}

#pragma mark - DELEGATES

//MARK: - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2) {
        return 205;
    }else{
        return 51;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2) {
        UseCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UseCardCell"];
        if (!cell) {
            cell = [[UseCardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UseCardCell"];
        }
        [cell.btnUse addTarget:self action:@selector(selectedUseCardButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        if (indexPath.row==0) {
            NewCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewCardCell"];
            if (!cell) {
                cell = [[NewCardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewCardCell"];
            }
            cell.delegate = self;
            [cell setLayoutWithIdx:indexPath number:cardNumber];
            
            return cell;
        }else{
            DateCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DateCardCell"];
            if (!cell) {
                cell = [[DateCardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DateCardCell"];
            }
            cell.delegate = self;
            [cell configCell:cardMonth year:cardYear cvv:cardCVV];
            
            return cell;
        }
    }
}

//MARK: - NewCardCell
- (void)endEditingInfoWithIndex:(NSIndexPath *)index string:(NSString *)text{
    if (index.row==0) {
        cardNumber = text;
    }
}

//MARK: - DateCardCell

- (void)endEditingDateCardDelegate:(NSString *)month year:(NSString *)year cvv:(NSString *)cvv{
    cardMonth = month;
    cardYear = year;
    cardCVV = cvv;
}

//MARK: - CardIO
- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    cardCVV = info.cvv;
    cardNumber = info.cardNumber;
    cardMonth = [NSString stringWithFormat:@"%d",(int)info.expiryMonth];
    cardYear = [NSString stringWithFormat:@"%d",(int)info.expiryYear];
    [self.tbView reloadData];
    // Use the card info...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
