//
//  VCOrderBulkAssign.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/10/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCOrderBulkAssign.h"
#import "KLCPopup.h"
#import "STCollapseTableView.h"
#import "OBHeaderView.h"
#import "OBBottomCell.h"
#import "DefaultButton.h"
#import "UITextView+Placeholder.h"
#import "VCOrderMapDetail.h"
#import "VCSender.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface VCOrderBulkAssign ()<UITableViewDataSource, UITableViewDelegate,STCollapseTableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UITextViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate>
{
    NSInteger noSection;
    NSString *code;
    CGFloat distance;
    int indexOrder;
    int timeRun;
    BOOL mapVisible;
    
    __weak IBOutlet NSLayoutConstraint *heightMainScroll;
}
@property (nonatomic, strong) NSMutableArray* data;
@property (nonatomic, strong) NSMutableArray* headers;

@property (weak, nonatomic) IBOutlet UILabel *pickupLocation;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UIButton *senderPhone;
@property (weak, nonatomic) IBOutlet UILabel *orderPrice;
@property (weak, nonatomic) IBOutlet UIImageView *senderAvatar;
@property (weak, nonatomic) IBOutlet UILabel *senderNameFull;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet STCollapseTableView *tbExpand;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTBExpand;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContent;
@property (weak, nonatomic) IBOutlet UITextField *tfCode;
@property (weak, nonatomic) IBOutlet DefaultButton *btnActions;
@property (strong, nonatomic) UITextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UIView *vCode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightScroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightMap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightBtnActions;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightAva2Bot;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseVConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnInformVConfirm;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderVConfirm;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmCode;
@property (weak, nonatomic) IBOutlet UIButton *btnCallVInform;
@property (weak, nonatomic) IBOutlet UIButton *btnCantDeliverVInform;
@property (weak, nonatomic) IBOutlet UIView *vMapDetail;

@end

@implementation VCOrderBulkAssign

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    distance = 157.0f;
    self.mainScrollView.hidden = YES;
    self.vCode.hidden = YES;
    
    [self configMap];
    [self setupHeader];
    
    [self refreshOrder];
    [self.mainScrollView addPullToRefreshWithActionHandler:^{
        [self refreshOrder];
    }];

    self.tbExpand.headerViewTapDelegate = self;
    self.tbExpand.collapseSectionDelegate = self;
    [self resizeTable];
    _tfCode.inputAccessoryView = [self createToolbarCancelForKeyBoard];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSender:)];
    self.senderAvatar.userInteractionEnabled = YES;
    [self.senderAvatar addGestureRecognizer:gr];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [KLCPopup dismissAllPopups];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeStatusOrder" object:nil];
}

- (void)showButtonAndStateWithState:(NSString*)state
{
    self.lblState.text = [[Util convertStateOrder:state] uppercaseString];
    [self.btnActions removeTarget:self action:NULL forControlEvents:UIControlEventAllTouchEvents];
     
    if ([state isEqualToString:stateKeyAccepted])
    {
        self.tfCode.placeholder = @"Pick up code";
        [self.btnActions setTitle:@"OTHER ACTIONS" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedCantPickUp) forControlEvents:UIControlEventTouchUpInside];
        self.vCode.hidden = NO;
    }else if ([state isEqualToString:stateKeyDelivery]){
        for (NSInteger i = 0; i < [self.currentOrder.arOrders count]; i++)
        {
            OBHeaderView *cell = (OBHeaderView *)[self.headers objectAtIndex:i];
            cell.lblOrderState.hidden = NO;
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"DELIVERY"])
            {
                cell.lblOrderState.text = @"DELIVERING";
                cell.lblOrderState.backgroundColor = [UIColor colorWithRed:234/255.0 green:30/255.0 blue:99/255.0 alpha:1];
                cell.btnLocation.hidden = ![self.tbExpand isOpenSection:i];
            }
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"RETURNING"])
            {
                cell.lblOrderState.text = @"RETURN TO OFFICE";
                cell.lblOrderState.backgroundColor = [UIColor colorWithRed:234/255.0 green:30/255.0 blue:99/255.0 alpha:1];
                cell.btnLocation.hidden = ![self.tbExpand isOpenSection:i];
            }
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"COMPLETED"])
            {
                cell.lblOrderState.text = @"DELIVERED";
                cell.lblOrderState.backgroundColor = UIColorFromRGB(0x29b6f6);
                cell.btnLocation.hidden = YES;
            }
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"IN_OFFICE"])
            {
                cell.lblOrderState.text = @"IN OFFICE";
                cell.lblOrderState.backgroundColor = UIColorFromRGB(0x29b6f6);
                cell.btnLocation.hidden = YES;
            }
            
            cell.imgArrow.image = [cell.imgArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.imgArrow setTintColor:[UIColor whiteColor]];
        }
        
        self.vCode.hidden = YES;
        self.heightScroll.constant = 0;
        self.heightMap.constant = 0;
        self.btnActions.hidden = YES;
        self.heightBtnActions.constant = 0;
        self.heightAva2Bot.constant = 30;
    }else if ([state isEqualToString:stateKeyCompleted] || [state isEqualToString:stateKeyReturned] || [state isEqualToString:stateKeyCancelled]){
        for (NSInteger i = 0; i < [self.currentOrder.arOrders count]; i++)
        {
            OBHeaderView *cell = (OBHeaderView *)[self.headers objectAtIndex:i];
            cell.lblOrderState.hidden = NO;
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"DELIVERY"])
            {
                cell.lblOrderState.text = @"DELIVERING";
                cell.lblOrderState.backgroundColor = [UIColor colorWithRed:234/255.0 green:30/255.0 blue:99/255.0 alpha:1];
                cell.btnLocation.hidden = ![self.tbExpand isOpenSection:i];
            }
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"RETURNING"])
            {
                cell.lblOrderState.text = @"RETURN TO OFFICE";
                cell.lblOrderState.backgroundColor = [UIColor colorWithRed:234/255.0 green:30/255.0 blue:99/255.0 alpha:1];
                cell.btnLocation.hidden = ![self.tbExpand isOpenSection:i];
            }
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"COMPLETED"])
            {
                cell.lblOrderState.text = @"DELIVERED";
                cell.lblOrderState.backgroundColor = UIColorFromRGB(0x29b6f6);
                cell.btnLocation.hidden = YES;
            }
            if ([[[self.currentOrder.arOrders objectAtIndex:i]objectForKeyedSubscript:@"state"]isEqualToString:@"IN_OFFICE"])
            {
                cell.lblOrderState.text = @"IN OFFICE";
                cell.lblOrderState.backgroundColor = UIColorFromRGB(0x29b6f6);
                cell.btnLocation.hidden = YES;
            }
            
            cell.imgArrow.image = [cell.imgArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.imgArrow setTintColor:[UIColor whiteColor]];
        }
        self.vCode.hidden = YES;
        self.heightScroll.constant = 0;
        self.heightMap.constant = 0;
        self.btnActions.hidden = NO;
        self.heightBtnActions.constant = 40;
        self.heightAva2Bot.constant = 65;
        
        [self.btnActions setTitle:@"NEXT BASKET" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedNextBasket) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //check if history
    if (self.isFromHistory)
    {
        self.vCode.hidden = YES;
        self.heightScroll.constant = 0;
        self.heightMap.constant = 0;
        self.btnActions.hidden = YES;
        self.heightBtnActions.constant = 0;
        self.heightAva2Bot.constant = 30;
    }
}

- (void)selectedNextBasket
{
    [HServiceAPI onCloseBulkOrder:^(BOOL finish, NSError *error)
     {
         if (!error)
         {
             [APPSHARE checkActiveOrder:NO];
             [OBulk deleteAllOrder];
             [APPSHARE addLeftPanelwithOrder:nil];
             [Util setObject:@"work" forKey:@"workstatus"];
         }
         else
         {
             [self errorHandler:error];
         }
     }];
}

- (void)selectedCantPickUp
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Choose an Action"
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Can't Pickup",@"Cancel this Order",nil];
    al.tag = 1;
    [al show];
}

- (void)selectedCantDelivery
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't deliver this order ?"
                                                message:@"Please choose option below to complete !"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call to Support",@"Return to Office",nil];
    al.tag = 4;
    [al show];
}

- (void)configMap
{
    [self.mapView clear];
    self.mapView.settings.rotateGestures = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.scrollGestures = NO;
    self.mapView.settings.zoomGestures = NO;
    [self.mapView.settings setAllGesturesEnabled:NO];
    self.mapView.settings.consumesGesturesInView = YES;
    self.mapView.userInteractionEnabled = NO;
    
    //marker
    GMSMarker *markerPickup = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon)];
    markerPickup.map = _mapView;
    markerPickup.icon = [UIImage imageNamed:@"pickUp"];
    markerPickup.groundAnchor = CGPointMake(0.5, 1);
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]init];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon)];
    
    for (OOrderAvailable *o in self.currentOrder.arOrders) {
        GMSMarker *markerDropOff = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon)];
        markerDropOff.map = _mapView;
        markerDropOff.icon = [UIImage imageNamed:@"dropOff"];
        markerDropOff.groundAnchor = CGPointMake(0.5, 1);
        
        bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon)];
    }
    
    if (self.isFromHistory)
    {}
    else
    {
        GMSMarker *pin = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
        pin.map = _mapView;
        pin.icon = [UIImage imageNamed:@"PinCourier"];
        pin.groundAnchor = CGPointMake(0.5, 1);
        
        bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    }
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(100, 50, 50, 50)];
    [self.mapView animateWithCameraUpdate:update];
    
    UITapGestureRecognizer *popupMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMap:)];
    [self.vMapDetail addGestureRecognizer:popupMap];
}

- (void)onClickMap:(UITapGestureRecognizer*)sender
{
    VCOrderMapDetail *mapDetail = VCORDER(VCOrderMapDetail);
    mapDetail.bulkJobs = self.currentOrder;
    mapDetail.isBulk = YES;
    [self.navigationController pushViewController:mapDetail animated:NO];
}

#pragma mark - STCollapseTableViewDelegate

- (void)STCollapseTableView:(STCollapseTableView *)STCollapseTableView didSelectHeaderViewAtSection:(NSInteger)section
{
    noSection = section;
}

-(void)didToggleSection:(NSUInteger)sectionIndex collapsed:(BOOL)collapsed
{
    OBHeaderView *cell = (OBHeaderView *)[self.headers objectAtIndex:sectionIndex];
    
    if (collapsed)
    {
        cell.imgArrow.image = [UIImage imageNamed:@"ArrowBlack.png"];
        cell.btnLocation.hidden = YES;
        self.heightTBExpand.constant -= [self calculatorDistanceWithIndex:sectionIndex];
        self.heightContent.constant -= [self calculatorDistanceWithIndex:sectionIndex];
        [self.view updateConstraintsIfNeeded];
        
    }
    else
    {
        cell.imgArrow.image = [UIImage imageNamed:@"downArrowBlack.png"];
        cell.btnLocation.hidden = NO;
        self.heightTBExpand.constant += [self calculatorDistanceWithIndex:sectionIndex];
        self.heightContent.constant += [self calculatorDistanceWithIndex:sectionIndex];
        [self.view updateConstraintsIfNeeded];
        
        OOrderAvailable *o = self.currentOrder.arOrders[sectionIndex];
        if ([o.state isEqualToString:stateKeyInOffice] || [o.state isEqualToString:stateKeyCompleted] || [o.state isEqualToString:stateKeyCancelled] || [o.state isEqualToString:stateKeyAccepted] || self.isFromHistory){
            cell.btnLocation.hidden = YES;
        }else{
            cell.btnLocation.hidden = NO;
        }
    }
    if (![self.currentOrder.state isEqualToString:stateKeyAccepted])
    {
        if (!self.isFromHistory)
        {
            cell.imgArrow.image = [cell.imgArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.imgArrow setTintColor:[UIColor whiteColor]];
        }
    }
}

- (void)refreshOrder
{
    RELOAD_MENU_LEFT
    if (APPSHARE.userLogin==nil)
    {
        [APPSHARE showLogin];
        [self.mainScrollView.pullToRefreshView stopAnimating];
        return;
    }
    
    if (self.isFromHistory)
    {
        [self setLayout];
//        [self configMap];
    }
    else
    {
        [HServiceAPI getCurrentActiveBulkOrder:^(NSDictionary *results, NSError *error) {
            if (!error)
            {
                OBulk *o = [OBulk convertToObject:results];
                [OBulk saveOrder:o];
                self.currentOrder = o;
                [self reloadHeader];
                [self setLayout];
            }
            else
            {
                [self errorHandler:error];
            }
            [self.mainScrollView.pullToRefreshView stopAnimating];
        }];

    }
}

- (void)setLayout
{
    //title
    self.title = [NSString stringWithFormat:@"Order #B%@",self.currentOrder.bid];
    
    //bulk general
    self.orderPrice.text = self.currentOrder.price;
    self.pickupLocation.text = self.currentOrder.pickUpAddress;
    self.senderName.text = self.currentOrder.senderName;
    [self.senderPhone setTitle:self.currentOrder.pickUpPhone forState:UIControlStateNormal];
   
    [self.senderAvatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.currentOrder.senderAvatar]] placeholderImage:avatarPlaceHolder];
    self.senderAvatar.layer.cornerRadius = self.senderAvatar.width/2;
    self.senderAvatar.layer.masksToBounds = YES;
    self.senderAvatar.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
    self.senderAvatar.layer.borderWidth = 2;
    self.senderNameFull.text = self.currentOrder.senderName;
    
    //state
    [self showButtonAndStateWithState:self.currentOrder.state];
    
    //config for notification order status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderStatusChanged:) name:@"changeStatusOrder" object:nil];
    
    [self.tbExpand reloadData];
    self.mainScrollView.hidden = NO;
}

- (void)orderStatusChanged:(NSNotification*)notification{
    [self refreshOrder];
}


- (void)onClickConfirmDelivery:(UIButton*)sender
{
    // border radius
    [_vConfirmDelivery.layer setCornerRadius:5.0f];
    
    // border
    [_vConfirmDelivery.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_vConfirmDelivery.layer setBorderWidth:0.5f];
    
    // drop shadow
    [_vConfirmDelivery.layer setShadowColor:[UIColor blackColor].CGColor];
    [_vConfirmDelivery.layer setShadowOpacity:0.5];
    [_vConfirmDelivery.layer setShadowRadius:1.0];
    [_vConfirmDelivery.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    
    _vConfirmDelivery.layer.cornerRadius = 5; // this value vary as per your desire
    _vConfirmDelivery.clipsToBounds = YES;
    [_btnCloseVConfirm addTarget:self action:@selector(onDismissPopup:) forControlEvents:UIControlEventTouchUpInside];
    [_btnInformVConfirm addTarget:self action:@selector(onInformPopup:) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    indexOrder = (int)clickedButtonIndexPath.section;

    OOrderAvailable *o = self.currentOrder.arOrders[(long)clickedButtonIndexPath.section];
    _lblOrderVConfirm.text = [NSString stringWithFormat:@"Order #%@",o.oid];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:_vConfirmDelivery showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    popup.tag = kTagKLCPopup;
    [popup show];
}

-(void)onDismissPopup:(id)sender
{
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView*)sender dismissPresentingPopup];
    }
}

-(void)onInformPopup:(id)sender
{
    // border radius
    [_vInform.layer setCornerRadius:5.0f];
    
    // border
    [_vInform.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_vInform.layer setBorderWidth:0.5f];
    
    // drop shadow
    [_vInform.layer setShadowColor:[UIColor blackColor].CGColor];
    [_vInform.layer setShadowOpacity:0.5];
    [_vInform.layer setShadowRadius:1.0];
    [_vInform.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    
    _vInform.layer.cornerRadius = 5; // this value vary as per your desire
    _vInform.clipsToBounds = YES;
    [_btnCallVInform addTarget:self action:@selector(onCall:) forControlEvents:UIControlEventTouchUpInside];
    
    //remove target if has before
    [_btnCantDeliverVInform removeTarget:self action:NULL forControlEvents:UIControlEventAllTouchEvents];
    
    OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
    if ([o.state isEqualToString:stateKeyDelivery])
    {
        [_btnCantDeliverVInform setTitle:@"CAN'T DELIVER" forState:UIControlStateNormal];
        [_btnCantDeliverVInform addTarget:self action:@selector(onCantDeliver:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [_btnCantDeliverVInform setTitle:@"OTHER ACTIONS" forState:UIControlStateNormal];
        [_btnCantDeliverVInform addTarget:self action:@selector(onClickOtherActions:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    KLCPopup* popup = [KLCPopup popupWithContentView:_vInform showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popup show];
}

- (void)onCall:(UIButton*)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    OOrderAvailable *o = self.currentOrder.arOrders[(long)clickedButtonIndexPath.section];
    [self makePhoneCall:o.phoneDropoff];
}

- (void)onCantDeliver:(UIButton*)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    indexOrder = (int)clickedButtonIndexPath.section;
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't deliver this order ?"
                                                message:@"Please choose option below to complete !"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call to Support",@"Return to Office",nil];
    al.tag = 4;
    [al show];
}

- (void)onClickCantDeliver:(UIButton*)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    indexOrder = (int)clickedButtonIndexPath.section;
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Choose an Action"
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call Receipient",@"Inform to Sender",@"Return to Office",nil];
    al.tag = 9;
    [al show];
}

#pragma mark - Tableview delegate

- (void)resizeTable
{
    self.heightTBExpand.constant = [self calculatorHeightTable];
    self.heightContent.constant = [self calculatorHeightTable] + 150;
    for (int i=0; i<self.currentOrder.arOrders.count; i++) {
        if ([self.tbExpand isOpenSection:i]) {
            self.heightContent.constant += [self calculatorDistanceWithIndex:i];
        }
    }
    
    [self.view updateConstraintsIfNeeded];
    [self.tbExpand setExclusiveSections:NO];
}
- (CGFloat)calculatorHeightTable{
    CGFloat height = 0;
    for (int i = 0;i<self.currentOrder.arOrders.count;i++) {
        height += 31 + [self calculatorHeightLableAddressWithSection:i] + 4;
    }
    
    return height;
}


- (CGFloat)calculatorHeightLableAddressWithSection:(NSInteger)section{
    OOrderAvailable *o = self.currentOrder.arOrders[section];
    CGFloat height = [o.dropoffAddress heightWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] forWidth:(SCREEN_WIDTH-76)];
    if (height>30) {
        return height;
    }else{
        return 30;
    }
}
- (void)setupHeader
{
    self.data = [[NSMutableArray alloc] init];
    
    self.headers = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [self.currentOrder.arOrders count] ; i++)
    {
        UIView *header = [[[NSBundle mainBundle] loadNibNamed:@"OBHeaderView" owner:self options:nil] firstObject];
        OBHeaderView *ob = (OBHeaderView *)header;
        OOrderAvailable *o = self.currentOrder.arOrders[i];
        ob.noOrder.text = [NSString stringWithFormat:@"%d",i+1];
        [ob.noOrder.layer setCornerRadius:10];
        ob.noOrder.clipsToBounds=YES;
        
        [ob.btnLocation addTarget:self action:@selector(onClickLocation:) forControlEvents:UIControlEventTouchUpInside];
        ob.btnLocation.tag = i;
        ob.btnLocation.hidden = YES;
        
        ob.lblOrderName.text = [NSString stringWithFormat:@"Order #%@",o.oid];
        ob.lblAddress.text = o.dropoffAddress;
        [self.headers addObject:header];
    }
}
- (void)reloadHeader{
    for (int i = 0;i<self.headers.count;i++) {
        OBHeaderView *ob = self.headers[i];
        OOrderAvailable *o = self.currentOrder.arOrders[i];
        
        ob.noOrder.text = [NSString stringWithFormat:@"%d",i+1];
        [ob.noOrder.layer setCornerRadius:10];
        ob.noOrder.clipsToBounds=YES;
        
        [ob.btnLocation addTarget:self action:@selector(onClickLocation:) forControlEvents:UIControlEventTouchUpInside];
        ob.btnLocation.tag = i;
        
        ob.lblOrderName.text = [NSString stringWithFormat:@"Order #%@",o.oid];
        ob.lblAddress.text = o.dropoffAddress;
    }
    [self resizeTable];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    DLog(@"index %lu",(unsigned long)[self.currentOrder.arOrders count]);
    if(![self.currentOrder.arOrders count])
        return 0;
    
    return [self.currentOrder.arOrders count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OBBottomCell"];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OBBottomCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    OOrderAvailable *o = self.currentOrder.arOrders[indexPath.section];
    OBBottomCell *ob = (OBBottomCell *)cell;
    ob.lblNote.text = o.note;
    ob.lblSenderName.text = o.receiverName;
    ob.lblTypePacket.text = [NSString stringWithFormat:@"%@ PARCEL",o.size];
    if ([o.size isEqualToString:@"SMALL"])
    {
        [ob.imvPacket setImage:[UIImage imageNamed:@"iconSmallPack.png"]];
    }
    if ([o.size isEqualToString:@"MEDIUM"])
    {
        [ob.imvPacket setImage:[UIImage imageNamed:@"iconMediumPack.png"]];
    }
    [ob.lblSenderPhone setTitle:o.phoneDropoff forState:UIControlStateNormal];
    
    //remove target if has before
    [ob.btnConfirmDelivery removeTarget:self action:NULL forControlEvents:UIControlEventAllTouchEvents];
    [ob.btnCantDeliver removeTarget:self action:NULL forControlEvents:UIControlEventAllTouchEvents];
    
    if (![o.state isEqualToString:stateKeyAccepted])
    {
        ob.heightButton.constant = 50;
        ob.btnCall.hidden = NO;
        ob.btnSMS.hidden = NO;
        ob.btnConfirmDelivery.hidden = NO;
        ob.btnCantDeliver.hidden = NO;
        if ([o.state isEqualToString:stateKeyDelivery])
        {
            self.tfConfirmCode.placeholder = @"Enter confirm code";
            [ob.btnConfirmDelivery setTitle:@"CONFIRM DELIVERY" forState:UIControlStateNormal];
            [ob.btnConfirmDelivery addTarget:self action:@selector(onClickConfirmDelivery:) forControlEvents:UIControlEventTouchUpInside];
            [ob.btnCantDeliver setTitle:@"CAN'T DELIVER" forState:UIControlStateNormal];
            [ob.btnCantDeliver addTarget:self action:@selector(onClickCantDeliver:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([o.state isEqualToString:stateKeyInOffice] || [o.state isEqualToString:stateKeyCompleted] || [o.state isEqualToString:stateKeyCancelled])
        {
            ob.heightButton.constant = 0;
            ob.btnConfirmDelivery.hidden = YES;
            ob.btnCantDeliver.hidden = YES;
            ob.btnCall.hidden = YES;
            ob.btnSMS.hidden = YES;

        }else if ([o.state isEqualToString:stateKeyReturning] || [o.state isEqualToString:stateKeyBackReturning])
        {
            self.tfConfirmCode.placeholder = @"Enter return code";
            [ob.btnConfirmDelivery setTitle:@"CONFIRM RETURN" forState:UIControlStateNormal];
            [ob.btnConfirmDelivery addTarget:self action:@selector(onClickConfirmReturn:) forControlEvents:UIControlEventTouchUpInside];
            [ob.btnCantDeliver setTitle:@"OTHER ACTIONS" forState:UIControlStateNormal];
            [ob.btnCantDeliver addTarget:self action:@selector(onClickOtherActions:) forControlEvents:UIControlEventTouchUpInside];
        }else
        {
            self.tfConfirmCode.placeholder = @"Enter confirm code";
        }
    }
    else
    {
        ob.btnCall.hidden = YES;
        ob.btnSMS.hidden = YES;
        ob.heightButton.constant = 0;
        ob.btnConfirmDelivery.hidden = YES;
        ob.btnCantDeliver.hidden = YES;
    }
    
    if (self.isFromHistory)
    {
        ob.heightButton.constant = 0;
        ob.btnConfirmDelivery.hidden = YES;
        ob.btnCantDeliver.hidden = YES;
        ob.btnCall.hidden = YES;
        ob.btnSMS.hidden = YES;
    }
    
    [ob.btnSMS addTarget:self action:@selector(onClickSMS:) forControlEvents:UIControlEventTouchUpInside];
    [ob.btnCall addTarget:self action:@selector(onClickCall:) forControlEvents:UIControlEventTouchUpInside];
    
    ob.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculatorDistanceWithIndex:indexPath.section];
    
}

- (CGFloat)calculatorDistanceWithIndex:(NSInteger)index{
    OOrderAvailable *o = self.currentOrder.arOrders[index];
    if ([o.state isEqualToString:stateKeyInOffice] || [o.state isEqualToString:stateKeyCompleted] || [o.state isEqualToString:stateKeyCancelled] || [o.state isEqualToString:stateKeyAccepted] || self.isFromHistory){
        distance = 107.0f;
    }else{
        distance = 157.0f;
        
    }
    if ([o.note heightWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] forWidth:(SCREEN_WIDTH-72)]>43){
        distance += [o.note heightWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f] forWidth:(SCREEN_WIDTH-72)];
    }else{
        distance += 43.0f;
    }
    return distance;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 31 + [self calculatorHeightLableAddressWithSection:section] + 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.headers objectAtIndex:section];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    KLCPopup *pop = [KLCPopup visiblePopup];
    [pop setFrame:CGRectMake(pop.frame.origin.x, pop.frame.origin.y - 30, pop.frame.size.width, pop.frame.size.height)];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
    NSString *state = o.state;
    
//    DLog(@"shouldChangeCharactersInRange...state=%@, strFinal=%@, string=%@", state, strFinal, string);
    
    if (strFinal.length > phoneCodeLength)
    {
        return NO;
    }
    
    if (strFinal.length == phoneCodeLength)
    {
        code = strFinal;
        if ([state isEqualToString:stateKeyAccepted])
        {
            [self verifyPickUp];
        }
        else if ([state isEqualToString:stateKeyDelivery])
        {
            [self verifyDeliver];
        }
        else if ([state isEqualToString:stateKeyReturning])
        {
            [self verifyReturn];
        }
    }
    return YES;
}

#pragma mark - TextView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //alert other actions
    if (alertView.tag == 1)
    {
        if (buttonIndex==0)
        {
            DLog(@"cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"cant pickup");
            [self CantPickUpAlert];
        }
        else if (buttonIndex==2)
        {
            DLog(@"cancel this order");
            [self CancelOrderAlert];
        }
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex==0)
        {
            DLog(@"Cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"Inform to Sender");
            [self makePhoneCall:self.currentOrder.pickUpPhone];
        }
        else if (buttonIndex==2)
        {
            DLog(@"Still can't Pick Up");
            [self CantPickup];
        }
        else if(buttonIndex==3)
        {}
    }
    else if (alertView.tag == 3)
    {
        if (buttonIndex==0)
        {
            DLog(@"Do not Cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"Cancel Order");
            [self showPopupReasonCancelOrder];
        }
    }
    else if (alertView.tag == CANCELLATION_ORDER_TAG)
    {
        if (buttonIndex == 0)
        {
            NSString *reasonContent = [self.reasonTextView.text stringRemoveSpace];
            if (reasonContent.length<1)
            {
                [self showErrorMessageWhenCancelOrderWithReason];
            }
            else
            {
                [self cancelOrderWithReason:@"OTHER" note:reasonContent];
            }
        }
    }
    else if (alertView.tag == 4)
    {
        if (buttonIndex==0)
        {
            DLog(@"Cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"Call Support");
            [self makePhoneCall:officePhone];
        }
        else if (buttonIndex==2)
        {
            DLog(@"Return to Office")
            [self returnSenderOrOffice:@"CANT_DELIVER" destination:@"OFFICE"];
        }
    }
    else if (alertView.tag == BACK_CANT_DELIVERY_SELECTION_WITH_RESUME_TAG)
    {
        if (buttonIndex==0)
        {
            DLog(@"Cancel");
        }else if (buttonIndex==1){
            DLog(@"call recipient");
            OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
            [self makePhoneCall:o.phoneDropoff];
        }else if (buttonIndex==2){
            DLog(@"inform sender");
            [self makePhoneCall:self.currentOrder.pickUpPhone];
        }else if (buttonIndex==3){
            DLog(@"recipient is back");
            [self resumeDelivery];
        }
    }
    else if (alertView.tag == 9)
    {
        if (buttonIndex==0)
        {
            DLog(@"Cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"Call Reciepient");
            OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
            [self makePhoneCall:o.phoneDropoff];
        }
        else if (buttonIndex==2)
        {
            DLog(@"Inform to Sender")
            [self makePhoneCall:self.currentOrder.pickUpPhone];
        }
        else if (buttonIndex==3)
        {
            DLog(@"Return to Office")
            [self returnSenderOrOffice:@"CANT_DELIVER" destination:@"OFFICE"];
        }
    }
}

-(void)resumeDelivery
{
    OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
    
    [HServiceAPI backResumeDeliveryBulkOrderCode:o.oid handler:^(BOOL finish, NSError *error)
    {
        if (!error)
        {
            [self refreshOrder];
            [KLCPopup dismissAllPopups];
        }
        else
        {
            [self errorHandler:error];
        }
    }];
}

-(void)returnSenderOrOffice:(NSString*)reason destination:(NSString*)destination
{
    OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
    
    [HServiceAPI cantDeliveryBulkOrder:o.oid reason:reason destination:destination handler:^(NSDictionary *results, NSError *error)
     {
         if (error==nil)
         {
             [self refreshOrder];
             [KLCPopup dismissAllPopups];
         }
         else
         {
             [self errorHandler:error];
         }
     }];
}

-(void)showErrorMessageWhenCancelOrderWithReason {
    
    UIAlertView *mAlert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                    message:@"Please enter a reason"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    mAlert.tag = RE_ENTER_REASON_CANCELLATION_ORDER_TAG;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 1, 260, 90)];
    
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont systemFontOfSize:14.0f]];
    label.backgroundColor = [UIColor redColor];
    
    [mAlert setValue: label forKey:@"accessoryView"];
    [mAlert show];
}

-(void) showPopupReasonCancelOrder {
    
    UIAlertView *mAlert = [[UIAlertView alloc]initWithTitle:@"Notice"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"CONFIRM",@"CANCEL",nil];
    mAlert.tag = CANCELLATION_ORDER_TAG;
    
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:@"" attributes:@{ NSParagraphStyleAttributeName : style}];
    
    self.reasonTextView = [[UITextView alloc]initWithFrame:CGRectMake(12, 1, 260, 90)];
    self.reasonTextView.editable = YES;
    self.reasonTextView.selectable = YES;
    self.reasonTextView.selectable = YES;
    self.reasonTextView.userInteractionEnabled = YES;
    self.reasonTextView.attributedText = attrText;
    self.reasonTextView.delegate = self;
    self.reasonTextView.enablesReturnKeyAutomatically = true;
    [self.reasonTextView setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    
    self.reasonTextView.placeholder = @"Enter a reason for cancellation";
    self.reasonTextView.placeholderColor = [UIColor lightGrayColor];
    [self.reasonTextView resignFirstResponder];
    
    [mAlert setValue: self.reasonTextView forKey:@"accessoryView"];
    [mAlert show];
}

- (void)CantPickup
{
    [HServiceAPI cancelBulkOrderWithId:self.currentOrder.bid reason:@"CANT_PICKUP" note:nil handler:^(NSDictionary *results, NSError *error)
     {
         if (!error)
         {
             [APPSHARE checkActiveOrder:NO];
             [OBulk deleteAllOrder];
             [APPSHARE clearBulkOrder];
             [APPSHARE addLeftPanelwithOrder:nil];
         }
         else
         {
             NSLog(@"cant cancel");
         }
     }];
}

- (void)cancelOrderWithReason:(NSString*)reason note:(NSString*)note
{
    [HServiceAPI cancelBulkOrderWithId:self.currentOrder.bid reason:@"OTHER" note:note handler:^(NSDictionary *results, NSError *error)
     {
         if (!error)
         {
             [APPSHARE checkActiveOrder:NO];
             [OBulk deleteAllOrder];
             [APPSHARE clearBulkOrder];
             [APPSHARE addLeftPanelwithOrder:nil];
         }
         else
         {
             NSLog(@"cant cancel");
         }
     }];
}

#pragma mark - UIScrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==self.mainScrollView) {
//        if (scrollView.contentOffset.y>350) {
//            mapVisible = NO;
//        }else{
//            if (scrollView.contentOffset.y==0 && mapVisible==NO) {
//                mapVisible = YES;
//                [self configMap];
//            }
//        }
    }
}

#pragma mark - Other

- (void)CantPickUpAlert
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't pick up this order ?"
                                                message:@"Please try to contact sender again before you cancel this order !"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call to Sender",@"Still can't Pick Up",@"Problem Solved",nil];
    al.tag = 2;
    [al show];
}

-(void)CancelOrderAlert
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you want to cancel this order ?"
                                                message:@"We are sorry to see you go, hope you will work with us again !"
                                               delegate:self
                                      cancelButtonTitle:@"Do not Cancel"
                                      otherButtonTitles:@"Cancel Order", nil];
    al.tag = 3;
    [al show];
}

- (void)verifyPickUp
{
    [HServiceAPI confirmPickupBulkCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             [self refreshOrder];
             [KLCPopup dismissAllPopups];
             
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfCode.text = @"";
         self.tfConfirmCode.text = @"";
         [self.tfCode resignFirstResponder];
     }];
}

- (void)verifyDeliver
{
    OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
    
    [HServiceAPI confirmDeliveryBulkCode:code withOrderId:o.oid block:^(BOOL finish, NSError *error)
     {
         if (!error)
         {
             
             self.heightTBExpand.constant -= 50;
             self.heightContent.constant -= 50;
             [self.view updateConstraintsIfNeeded];
             
             [self refreshOrder];
             [KLCPopup dismissAllPopups];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfCode.text = @"";
         self.tfConfirmCode.text = @"";
         [self.tfCode resignFirstResponder];
     }];
}

- (void)verifyReturn
{
    OOrderAvailable *o = self.currentOrder.arOrders[indexOrder];
    
    [HServiceAPI returnBulkOfficeCode:code withOrderId:o.oid block:^(BOOL finish, NSError *error)
    {
        if (!error)
        {
            self.heightTBExpand.constant -= 50;
            self.heightContent.constant -= 50;
            [self.view updateConstraintsIfNeeded];

            [self refreshOrder];
            [KLCPopup dismissAllPopups];
        }
        else
        {
            [self errorHandler:error];
        }
        self.tfCode.text = @"";
        self.tfConfirmCode.text = @"";
        [self.tfCode resignFirstResponder];
    }];
}

-(void)makePhoneCall:(NSString *)phone
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",phone]];
    
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
}

- (void)onClickLocation:(UIButton*)sender
{
    if (sender.tag<self.currentOrder.arOrders.count)
    {
        OOrderAvailable *o = self.currentOrder.arOrders[sender.tag];
        
        [self showPopUpOpenMapsWithLocation:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon) pickUp:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon) pickUpAddress:self.currentOrder.pickUpAddress dropOffAddress:o.dropoffAddress showOnlyPickUp:NO];
    }
}

- (void)onClickSMS:(UIButton*)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    OOrderAvailable *o = self.currentOrder.arOrders[(long)clickedButtonIndexPath.section];
    [self showSMS:@"content" withNumber:(NSString*)o.phoneDropoff];
}

//Message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(NSString*)file withNumber:(NSString*)number
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[number];
    NSString *message = @"Please input your message !";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)onClickCall:(UIButton*)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    OOrderAvailable *o = self.currentOrder.arOrders[(long)clickedButtonIndexPath.section];
    [self makePhoneCall:o.phoneDropoff];
}

- (void)onClickConfirmReturn:(UIButton*)sender
{
    // border radius
    [_vConfirmDelivery.layer setCornerRadius:5.0f];
    
    // border
    [_vConfirmDelivery.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_vConfirmDelivery.layer setBorderWidth:0.5f];
    
    // drop shadow
    [_vConfirmDelivery.layer setShadowColor:[UIColor blackColor].CGColor];
    [_vConfirmDelivery.layer setShadowOpacity:0.5];
    [_vConfirmDelivery.layer setShadowRadius:1.0];
    [_vConfirmDelivery.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    
    _vConfirmDelivery.layer.cornerRadius = 5; // this value vary as per your desire
    _vConfirmDelivery.clipsToBounds = YES;
    [_btnCloseVConfirm addTarget:self action:@selector(onDismissPopup:) forControlEvents:UIControlEventTouchUpInside];
    [_btnInformVConfirm addTarget:self action:@selector(onInformPopup:) forControlEvents:UIControlEventTouchUpInside];
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    indexOrder =(int)clickedButtonIndexPath.section;
    
    OOrderAvailable *o = self.currentOrder.arOrders[(long)clickedButtonIndexPath.section];
    _lblOrderVConfirm.text = [NSString stringWithFormat:@"Order #%@",o.oid];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:_vConfirmDelivery showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [popup show];
}

- (void)onClickOtherActions:(UIButton*)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tbExpand]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.tbExpand indexPathForRowAtPoint:touchPoint];
    
    indexOrder =(int)clickedButtonIndexPath.section;
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't return this order ?"
                                                message:@"Please choose option below to complete !"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call recipient",@"Inform Sender",@"Recipient is back,deliver to him",nil];
    al.tag = BACK_CANT_DELIVERY_SELECTION_WITH_RESUME_TAG;
    [al show];
}

-(void)onClickSender:(UITapGestureRecognizer*)sender
{
    VCSender *vc = VCORDER(VCSender);
    vc.senderAvatar = self.currentOrder.senderAvatar;
    vc.senderPhone = self.currentOrder.pickUpPhone;
    vc.senderName = self.currentOrder.senderName;
    self.senderAvatar.userInteractionEnabled = NO;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)showPopUpOpenMapsWithLocation:(CLLocationCoordinate2D)dropOffLocation pickUp:(CLLocationCoordinate2D)pickUpLocation pickUpAddress:(NSString*)pickUpAddress dropOffAddress:(NSString*)dropOffAddress showOnlyPickUp:(BOOL)showOnlyPickUp{
    UIAlertController * alertController=   [UIAlertController alertControllerWithTitle:@"Route with ..."
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* maps = [UIAlertAction
                           actionWithTitle:@"This application"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //go to maps in app
                               VCOrderMapDetail *mapDetail = VCORDER(VCOrderMapDetail);
                               mapDetail.pickUpAddress = pickUpAddress;
                               mapDetail.pickUpLocation = pickUpLocation;
                               mapDetail.dropOffLocation = dropOffLocation;
                               mapDetail.dropOffAddress = dropOffAddress;
                               mapDetail.isBulk = NO;
                               mapDetail.isNotShowDropOff = showOnlyPickUp;
                               [self.navigationController pushViewController:mapDetail animated:NO];
                               
                           }];
    [alertController addAction:maps];
    
    UIAlertAction* mapApple = [UIAlertAction
                         actionWithTitle:@"Apple maps"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //go to google map
                             NSString *strUrl;
                             if (!showOnlyPickUp) {
                                 strUrl = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%f,%f&q=%@&z=7",dropOffLocation.latitude,dropOffLocation.longitude,dropOffAddress.urlEncode];
                             }else{
                                 strUrl = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%f,%f&q=%@&z=7",pickUpLocation.latitude,pickUpLocation.longitude,pickUpAddress.urlEncode];
                             }
//                             DLog(@"strUrl = %@",strUrl);
                             if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:strUrl]]){
                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
                             }
                         }];
    [alertController addAction:mapApple];
    
    UIAlertAction* cancel = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //nothing action
                                   
                                   
                               }];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)selectedOpenMapsForPickUpAddress:(id)sender {
    [self showPopUpOpenMapsWithLocation:CLLocationCoordinate2DMake(0, 0) pickUp:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon) pickUpAddress:self.currentOrder.pickUpAddress dropOffAddress:nil showOnlyPickUp:YES];
}


@end
