//
//  VCOrderAssign.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCOrderAssign.h"
#import "LabelColor.h"
#import "DefaultButton.h"
#import "VCCommentOrder.h"
#import "VCOrderAvailable.h"
#import "DALabeledCircularProgressView.h"
#import "UIView+Toast.h"
#import "VCSender.h"
#import "AddressBook/AddressBook.h"
#import "AddressBookUI/AddressBookUI.h"
#import "UITextView+Placeholder.h"
#import "KLCPopup.h"
#import "VCOrderMapDetail.h"

#define WAIT_10_MINUTES     600/*Test 1minute*/;//600;
#define WAIT_5_MINUTES      300/*Test 1minute*/;//300;

@interface VCOrderAssign ()<UIAlertViewDelegate,VCCommentDelegate,UITextFieldDelegate, UITextViewDelegate,UIGestureRecognizerDelegate>{
    NSString *code;
    
    NSTimer *timerDelivering;
    NSTimer *timerRefresh;
    
    int secondsWaitingTotal;
    int secondsUntilFinished;
    BOOL isShowSelectionBackWait;
}

@property (strong, nonatomic) NSTimer *waitingTimer;
@property (strong, nonatomic) IBOutlet DALabeledCircularProgressView *waitingProgressView;
@property (weak, nonatomic) IBOutlet UIView *viewCountDown;

@property (weak, nonatomic) IBOutlet UIScrollView *scView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContentScView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewConfirmCode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topscView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTop;
@property (weak, nonatomic) IBOutlet UILabel *lbNotePickup;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceConfirmCode;
@property (weak, nonatomic) IBOutlet UILabel *lbConfirmCodeNote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceScrollViewToTop;

@property (weak, nonatomic) IBOutlet UILabel *lbState;
@property (weak, nonatomic) IBOutlet UIView *vConfirmCode;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmCode;
@property (weak, nonatomic) IBOutlet UIImageView *imvClock;
@property (weak, nonatomic) IBOutlet UILabel *lbTimer;

@property (weak, nonatomic) IBOutlet UIView *vState;
@property (weak, nonatomic) IBOutlet UIView *vTwoWays;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewTwoWays;

@property (weak, nonatomic) IBOutlet UIView *tfDetail;
@property (weak, nonatomic) IBOutlet UIView *vButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewButton;
@property (weak, nonatomic) IBOutlet UIButton *btnPhonePickup;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneDropoff;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet DefaultButton *btnActions;

@property (weak, nonatomic) IBOutlet UILabel *lbPickUpAddress;

@property (weak, nonatomic) IBOutlet UILabel *lbDropOffAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbDeliveryType;

@property (weak, nonatomic) IBOutlet UIImageView *imvPackage;
@property (weak, nonatomic) IBOutlet UILabel *lbSize;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbNote;

@property (weak, nonatomic) IBOutlet UIImageView *imvLineDash;
@property (weak, nonatomic) IBOutlet UIImageView *imvSender;
@property (weak, nonatomic) IBOutlet UILabel *lbSenderName;

@property (weak, nonatomic) IBOutlet UILabel *lbSenderNameNote;
@property (weak, nonatomic) IBOutlet UILabel *lbDropoffNameNote;

@property (weak, nonatomic) IBOutlet UILabel *lbPickupAdd;
@property (weak, nonatomic) IBOutlet UILabel *lbDropoffAdd;

@property (strong, nonatomic) UITextView *reasonTextView;
@property (strong, nonatomic) UIAlertView *currentBackWaitAlert;
@property (strong, nonatomic) UIAlertView *currentCancelOrderWaiting;

@end

@implementation VCOrderAssign

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self configMap];
    [self.scView addPullToRefreshWithActionHandler:^{
        [self refreshOrder];
    }];
    [self initComponents];
}

-(void) initComponents {
    //ready show popup selection back waiting
    isShowSelectionBackWait = false;
    //reset progress percent equals zero
    [self.waitingProgressView setProgress:0.0f animated:YES];
    
    self.waitingProgressView.roundedCorners = YES;
    self.waitingProgressView.progressTintColor = [UIColor colorWithRed:0.322 green:0.773 blue:0.922 alpha:1.00];
    self.waitingProgressView.trackTintColor = [UIColor colorWithRed:0.373 green:0.373 blue:0.373 alpha:1.00];
    [self.waitingProgressView.progressLabel setTextColor:[UIColor colorWithRed:0.322 green:0.773 blue:0.922 alpha:1.00]];
    [self.waitingProgressView.progressLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:28]];
    [self.waitingProgressView setThicknessRatio:0.22];
    self.viewCountDown.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.65f];
}

-(void)receivedNotifNewTokenRequiredForAccount:(NSNotification *)notification {
    //When login from other device same account
    if (notification != nil) {
        [self stopTimer];
        [self dismissBackWaitAlert];
        [self dismissCancelOrderWait];
    }

}
-(void)receivedNotifForRestartTimer:(NSNotification *)notification {
    //When login from other device same account
    if (notification != nil)
    {
        
        [self stopTimer];
        [self dismissBackWaitAlert];
        [self dismissCancelOrderWait];
        
        if ([stateKeyWaiting isEqualToString:self.currentOrder.state])
        {
            isShowSelectionBackWait = FALSE;
        }
        
        [self waitingTimeHandler:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self waitingTimeHandler:YES];
    [self setLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshOrder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTimer];
    
    [self dismissBackWaitAlert];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeStatusOrder" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stop_timer_if_waiting_time_return_trip" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"restart_timer_if_waiting_time_return_trip" object:nil];
    [timerDelivering invalidate];
    timerDelivering = nil;
    [timerRefresh invalidate];
    timerRefresh = nil;
}

- (void)dismissBackWaitAlert
{
    if (self.currentBackWaitAlert)
    {
        [self.currentBackWaitAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
}

- (void)dismissCancelOrderWait
{
    if (self.currentCancelOrderWaiting)
    {
        [self.currentCancelOrderWaiting dismissWithClickedButtonIndex:-1 animated:NO];
    }
}

- (void)refreshOrder
{
    RELOAD_MENU_LEFT
    if (APPSHARE.userLogin==nil) {
        [APPSHARE showLogin];
        [self.scView.pullToRefreshView stopAnimating];
        return;
    }
    if (![OrderHelper checkNeedRefreshOrder:self.currentOrder])
    {
        [self.scView.pullToRefreshView stopAnimating];
        [self setLayout];
        return;
    }
    
    if (self.isFromHistory)
    {
        [self configMap];
        [self setLayout];
    }
    else
    {
        [HServiceAPI getCurrentActiveOrder:^(NSArray *results, NSError *error)
         {
             if (!error)
             {
                 OOrderAvailable *o = results[0];
                 self.currentOrder = o;
                 [OOrderAvailable saveOrder:o];
                 [[WatchManager shared] sendStatusOrder:o];
                 [self configMap];
                 [self setLayout];
             }
             else
             {
                 [self errorHandler:error];
             }
             [self.scView.pullToRefreshView stopAnimating];
         }];
    }
    
}

- (void)orderStatusChanged:(NSNotification*)notification{
    [self refreshOrder];
}

#pragma mark - LAYOUT

- (void)configMap
{
    self.mapView.settings.rotateGestures = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.scrollGestures = NO;
    self.mapView.settings.zoomGestures = NO;
    [self.mapView.settings setAllGesturesEnabled:NO];
    self.mapView.settings.consumesGesturesInView = YES;
    self.mapView.userInteractionEnabled = NO;
    
    //marker
    GMSMarker *pickup = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon)];
    pickup.map = _mapView;
    pickup.icon = [UIImage imageNamed:@"pickUp"];
    pickup.title = self.currentOrder.pickupAddress;
    pickup.snippet = self.currentOrder.pickupAddressDetail;
    pickup.groundAnchor = CGPointMake(0.5, 1);
    
    GMSMarker *dropoff = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.currentOrder.dropOffLat, self.currentOrder.dropOffLon)];
    dropoff.map = _mapView;
    dropoff.icon = [UIImage imageNamed:@"dropOff"];
    dropoff.title = self.currentOrder.dropoffAddress;
    dropoff.snippet = self.currentOrder.dropoffAddressDetail;
    dropoff.groundAnchor = CGPointMake(0.5, 1);
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]init];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon)];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(self.currentOrder.dropOffLat, self.currentOrder.dropOffLon)];
    
    if (self.isFromHistory)
    {
    }
    else
    {
        GMSMarker *pin = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
        pin.map = _mapView;
        pin.icon = [UIImage imageNamed:@"PinCourier"];
        
        bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    }
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(130, 50, 50, 50)];
    [self.mapView animateWithCameraUpdate:update];
    
}

- (void)setLayout
{
    if (self.currentOrder.isReturnTrip)
    {
        [self.lbDeliveryType setText:@"DELIVERY TYPE : RETURN TRIP"];
    }
    else
    {
        [self.lbDeliveryType setText:@"DELIVERY TYPE : ONE WAY"];
    }
    
    self.lbSize.text = self.currentOrder.size;
    self.lbPrice.text = self.currentOrder.price;
    self.imvPackage.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@",self.currentOrder.size.lowercaseString]];
    
    self.lbPickUpAddress.text = self.currentOrder.pickupAddress;
    
    self.lbDropOffAddress.text = self.currentOrder.dropoffAddress;
    
    self.imvLineDash.image = [Util createimageLineDashWithHeight:self.imvLineDash.bounds.size.height withColor:UIColorFromRGB(0x333333)];
    
    self.title = [NSString stringWithFormat:@"Order #%@",self.currentOrder.oid];
    
    //timer delivering
    if ([OrderHelper isShowTimerDelivering:self.currentOrder])
    {
        self.imvClock.hidden = NO;
        self.lbTimer.hidden = NO;
        NSString *timeStartedString = [self calculatorTimerStart: self.currentOrder];
        DLog("timeStartedString=%@", timeStartedString);
        
        //timeStartedString
        self.lbTimer.text = timeStartedString;
        /*if (!timerDelivering.isValid)
         {
         __typeof(self) __weak welf = self;
         timerDelivering = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^{
         self.lbTimer.text = [OrderHelper calculatorTimerStart:welf.currentOrder];
         }];
         }*/
    }
    else
    {
        self.imvClock.hidden = YES;
        self.lbTimer.hidden = YES;
        [timerDelivering invalidate];
        timerDelivering = nil;
    }
    
    if ([OrderHelper checkNeedRefreshOrder:self.currentOrder]) {
        [timerRefresh invalidate];
        timerRefresh = nil;
        timerRefresh = [NSTimer scheduledTimerWithTimeInterval:currentOrderRefreshInterval repeats:YES block:^{
            [self refreshOrder];
        }];
        //config for notification order status
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderStatusChanged:) name:@"changeStatusOrder" object:nil];
    }
    
    [self.btnPhonePickup setTitle:self.currentOrder.phonePickup forState:UIControlStateNormal];
    [self.btnPhonePickup addTarget:self action:@selector(onSelectedPhone:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPhoneDropoff setTitle:self.currentOrder.phoneDropoff forState:UIControlStateNormal];
    [self.btnPhoneDropoff addTarget:self action:@selector(onSelectedPhone:) forControlEvents:UIControlEventTouchUpInside];
    self.lbNote.text = self.currentOrder.note;
    self.lbSenderName.text = self.currentOrder.senderName;
    NSLog(@"link image %@",self.currentOrder.senderPhoto);
    [self.imvSender sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.currentOrder.senderPhoto]] placeholderImage:avatarPlaceHolder];
    self.imvSender.layer.cornerRadius = self.imvSender.width/2;
    self.imvSender.layer.masksToBounds = YES;
    self.imvSender.layer.borderColor = [UIColorFromRGB(0xcccccc) CGColor];
    self.imvSender.layer.borderWidth = 2;
    
    self.lbSenderNameNote.text = self.currentOrder.senderName;
    self.lbDropoffNameNote.text = self.currentOrder.receiverName;
    [self.tfConfirmCode setValue:[UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1]forKeyPath:@"_placeholderLabel.textColor"];
    
    self.lbPickupAdd.text = self.currentOrder.pickupAddressDetail;
    self.lbDropoffAdd.text = self.currentOrder.dropoffAddressDetail;
    self.tfConfirmCode.inputAccessoryView = [self createToolbarCancelForKeyBoard];

    //remove button action target
    [self.btnActions removeTarget:nil
                           action:NULL
                 forControlEvents:UIControlEventAllEvents];
    
    //trang thai note 2nd
    if ([self.currentOrder.state isEqualToString:stateKeyWaiting])
    {
        self.lbNotePickup.hidden = NO;
        self.lbConfirmCodeNote.hidden = YES;
        self.tfConfirmCode.text = @"";
        self.tfConfirmCode.placeholder = @"Pick up code";
        self.heightViewConfirmCode.constant= 60.0;
        self.distanceScrollViewToTop.constant = 60;
        self.spaceConfirmCode.constant= 25.0;
    }
    else
    {
        self.lbNotePickup.hidden = YES;
        self.heightViewConfirmCode.constant= 40.0;
        self.distanceScrollViewToTop.constant = 40;
        self.spaceConfirmCode.constant= 5.0;
    }
    
    //state
    [self showButtonAndStateWithState:self.currentOrder.state isReturnTrip:self.currentOrder.isReturnTrip];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSender:)];
    self.imvSender.userInteractionEnabled = YES;
    [self.imvSender addGestureRecognizer:gr];
    
    UITapGestureRecognizer *popupMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMap:)];
    self.viewCountDown.userInteractionEnabled = YES;
    [self.viewCountDown addGestureRecognizer:popupMap];
    
    if (self.isFromHistory)
    {
        if ([self.currentOrder.state isEqualToString:stateKeyAdminCancelled] || [self.currentOrder.state isEqualToString:stateKeyCancelled])
        {
            self.lbTimer.hidden = YES;
            self.imvClock.hidden = YES;
        }
        else
        {
            self.lbTimer.hidden = NO;
            self.imvClock.hidden = NO;
        }
        
        NSMutableString *timeLeft = [[NSMutableString alloc]init];
        
        NSInteger seconds = [self.currentOrder.timeFinish timeIntervalSinceDate:self.currentOrder.timeStart];
        
        NSInteger days = (int) (floor(seconds / (3600 * 24)));
        if(days) seconds -= days * 3600 * 24;
        
        NSInteger hours = (int) (floor(seconds / 3600));
        if(hours) seconds -= hours * 3600;
        
        NSInteger minutes = (int) (floor(seconds / 60));
        if(minutes) seconds -= minutes * 60;
        
        if(hours) {
            [timeLeft appendString:[NSString stringWithFormat: @"%ld H", (long)hours*-1]];
        }
        
        if(minutes) {
            [timeLeft appendString: [NSString stringWithFormat: @"%ld M",(long)minutes*-1]];
        }
        
        NSLog(@"time left %@",timeLeft);
        self.lbTimer.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)hours,(long)minutes];
        
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.scView.bounces = NO;
        [self.vConfirmCode removeFromSuperview];
        [self.btnActions setHidden:YES];
        self.heightViewConfirmCode.constant=0.0;
        self.topscView.constant=0;
        self.heightTop.constant=320;
    }
    
    //notification timer
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedNotifNewTokenRequiredForAccount:) name:@"stop_timer_if_waiting_time_return_trip" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedNotifForRestartTimer:) name:@"restart_timer_if_waiting_time_return_trip" object:nil];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

-(void)onClickMap:(UITapGestureRecognizer*)sender
{
    if ([stateKeyWaiting isEqualToString:self.currentOrder.state])
    {
        // border radius
        [_popTimeClock.layer setCornerRadius:5.0f];
        
        // border
        [_popTimeClock.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [_popTimeClock.layer setBorderWidth:0.5f];
        
        // drop shadow
        [_popTimeClock.layer setShadowColor:[UIColor blackColor].CGColor];
        [_popTimeClock.layer setShadowOpacity:0.5];
        [_popTimeClock.layer setShadowRadius:1.0];
        [_popTimeClock.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
        
        _btnDismiss.layer.cornerRadius = 5; // this value vary as per your desire
        _btnDismiss.clipsToBounds = YES;
        [_btnDismiss addTarget:self action:@selector(onDismissPopup:) forControlEvents:UIControlEventTouchUpInside];
        
        KLCPopup* popup = [KLCPopup popupWithContentView:_popTimeClock showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [popup show];
    }
    else
    {
//        VCOrderMapDetail *order = VCORDER(VCOrderMapDetail);
//        order.currentOrder = self.currentOrder;
//        [self.navigationController pushViewController:order animated:YES];
    }
}

-(void)onDismissPopup:(id)sender
{
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView*)sender dismissPresentingPopup];
    }
}

-(void)onClickSender:(UITapGestureRecognizer*)sender
{
    VCSender *vc = VCORDER(VCSender);
    vc.senderAvatar = self.currentOrder.senderPhoto;
    vc.senderPhone = self.currentOrder.phonePickup;
    vc.senderName = self.currentOrder.senderName;
    self.imvSender.userInteractionEnabled = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)onSelectedPhone:(id)sender
{
    NSInteger tid = ((UIControl *) sender).tag;
    NSString *phNo;
    if (tid == 1)
    {
        phNo = self.currentOrder.phonePickup;
    }
    else
    {
        phNo = self.currentOrder.phoneDropoff;
    }
    [self makePhoneCall:phNo];
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

#pragma mark - FUNCTIONS

- (void)showButtonAndStateWithState:(NSString*)state isReturnTrip:(BOOL)isReturnTrip
{
    self.lbState.text = [[Util convertStateOrder:state] uppercaseString];
    
    if ([state isEqualToString:stateKeyAccepted])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.tfConfirmCode.placeholder = @"Pick up code";
        self.lbConfirmCodeNote.text = @"Pick up code";
        [self.btnActions setTitle:@"OTHER ACTIONS" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedCantPickUp) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([state isEqualToString:stateKeyDelivery])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.tfConfirmCode.placeholder = @"Delivery code";
        self.lbConfirmCodeNote.text = @"Delivery code";
        [self.btnActions setTitle:@"CAN'T DELIVER" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedCantDelivery) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([state isEqualToString:stateKeyReturning])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.tfConfirmCode.placeholder = @"Return code";
        self.lbConfirmCodeNote.text = @"Return code";
        [self.btnActions setTitle:@"OTHER ACTIONS" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedResumeDelivery) forControlEvents:UIControlEventTouchUpInside];
        if([self.currentOrder.returnDropoff isEqualToString:@"OFFICE"])
        {
            self.lbState.text = @"RETURNING TO OFFICE";
        }
        if([self.currentOrder.returnDropoff isEqualToString:@"PICKUP_LOCATION"])
        {
            self.lbState.text = @"RETURNING TO SENDER";
        }
    }
    if ([state isEqualToString:stateKeyReturned])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.heightViewConfirmCode.constant=0.0;
        self.topscView.constant=0;
        self.vConfirmCode.hidden = YES;
        [self.btnActions setTitle:@"NEXT ORDER" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedNextOrder) forControlEvents:UIControlEventTouchUpInside];
        self.lbState.text = @"RETURNED";
    }
    if ([state isEqualToString:stateKeyCancelled] || (isReturnTrip && [stateKeyCancelled isEqualToString:state]))
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        [timerRefresh invalidate];
        timerRefresh = nil;
        self.imvClock.hidden = YES;
        self.lbTimer.hidden = YES;
        self.heightViewConfirmCode.constant=0.0;
        self.topscView.constant=0;
        self.vConfirmCode.hidden = YES;
        [self.btnActions setTitle:@"NEXT ORDER" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedNextOrder) forControlEvents:UIControlEventTouchUpInside];
        self.lbState.text = @"CANCELLED";
    }
    
    /**
     * Upgrades for return trip function
     */
    
    if (isReturnTrip && [stateValueWaiting isEqualToString:state])
    {
        self.tfConfirmCode.placeholder = @"Pick up code";
        self.lbConfirmCodeNote.text = @"Pick up code";
        //Handler waiting time when wait confirm back pickup code
        //get number seconds in cache
        
        int waitingTimeTotal = [AuthManager getWaitingTimeTotal];
        int secondRemaining = [AuthManager getTimeRemainingSecond];
        long long latestWaitingTime = [AuthManager getLatestWaitingTime];
        
        if (waitingTimeTotal == 0 || secondRemaining < 1) {
            
            [self waitingTimeHandler: YES];
        } else {
            [self waitingCountDownViaServerHandler: waitingTimeTotal secondRemaining:secondRemaining latestWaitingTime:latestWaitingTime animated:YES];
        }
        [self.viewCountDown setAlpha:1];
        [self.waitingProgressView setHidden:NO];
        
        [self.btnActions setHidden:YES];
        self.lbState.text = @"WAITING";
    }

    else if (isReturnTrip && [state isEqualToString:stateKeyBackDelivery])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.tfConfirmCode.placeholder = @"Delivery code";
        self.lbConfirmCodeNote.text = @"Delivery code";
        [self.btnActions setTitle:@"CAN'T DELIVER" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectionBackCantDelivery) forControlEvents:UIControlEventTouchUpInside];
        [self.btnActions setHidden:NO];
        
        self.lbState.numberOfLines = 2;
        [self.lbState setLineBreakMode:NSLineBreakByWordWrapping];
        [self.lbState setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        self.lbState.text = @"ORDER COMPLETING\nRETURNING BACK";
    }
    else if (isReturnTrip && [stateKeyBackReturning isEqualToString:state])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.tfConfirmCode.placeholder = @"Return code";
        self.lbConfirmCodeNote.text = @"Return code";
        [self.btnActions setTitle:@"OTHER ACTIONS" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectionBackCantDeliveryWithResumeDelivery) forControlEvents:UIControlEventTouchUpInside];
        
        if([@"OFFICE" isEqualToString:self.currentOrder.returnDropoff])
        {
            self.lbState.text = @"RETURNING TO OFFICE";
        }
        if([@"PICKUP_LOCATION" isEqualToString:self.currentOrder.returnDropoff]
           || [@"DESTINATION_LOCATION" isEqualToString:self.currentOrder.returnDropoff])
        {
            self.lbState.text = @"RETURNING TO RECEIVER";
        }
    }
    else if ([stateKeyBackReturned isEqualToString:state])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.heightViewConfirmCode.constant=0.0;
        self.topscView.constant=0;
        self.heightTop.constant=320;
        self.vConfirmCode.hidden = YES;
        [self.btnActions setTitle:@"NEXT ORDER" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedNextOrder) forControlEvents:UIControlEventTouchUpInside];
        self.lbState.text = @"BACK RETURNED";
    }
    else if ([stateKeyInOffice isEqualToString:state])
    {
        [self.viewCountDown setAlpha:0.05];
        [self.waitingProgressView setHidden:YES];
        
        self.heightViewConfirmCode.constant=0.0;
        self.topscView.constant=0;
        self.heightTop.constant=320;
        self.vConfirmCode.hidden = YES;
        [self.btnActions setTitle:@"NEXT ORDER" forState:UIControlStateNormal];
        [self.btnActions addTarget:self action:@selector(selectedNextOrder) forControlEvents:UIControlEventTouchUpInside];
        self.lbState.text = @"IN OFFICE";
    }
    if ([stateKeyAdminCancelled isEqualToString:state])
    {
        if (self.isFromHistory)
        {
            [self.viewCountDown setAlpha:0.05];
            [self.waitingProgressView setHidden:YES];
            
            self.imvClock.hidden = YES;
            self.lbTimer.hidden = YES;
            self.lbState.text = @"DELIVERY FAILURE";
            self.heightViewConfirmCode.constant=0.0;
            self.topscView.constant=0;
            self.heightTop.constant=320;
            self.vConfirmCode.hidden = YES;
        }
        else
        {
            //show popup
            NSString *msg = [NSString stringWithFormat:@"Your Order #%@ has been cancelled by Zap Administrator !",self.currentOrder.oid];
            UIAlertView *pop = [[UIAlertView alloc]initWithTitle:@"Notice"
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [pop show];

            [timerRefresh invalidate];
            timerRefresh = nil;
            self.imvClock.hidden = NO;
            self.lbTimer.hidden = NO;
            
            [self.viewCountDown setAlpha:0.05];
            [self.waitingProgressView setHidden:YES];
            
            self.heightViewConfirmCode.constant=0.0;
            self.topscView.constant=0;
            self.heightTop.constant=320;
            self.vConfirmCode.hidden = YES;
            [self.btnActions setTitle:@"NEXT ORDER" forState:UIControlStateNormal];
            [self.btnActions addTarget:self action:@selector(selectedNextOrder) forControlEvents:UIControlEventTouchUpInside];
            self.lbState.text = @"DELIVERY FAILURE";
        }
    }
}

/**
 * Upgrades for return trip function
 */
-(void)selectionBackCantDelivery
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't deliver this order ?"
                                                message:@"Please choose option below to complete !"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call to Support",@"Return to Receiver",@"Return to Office",nil];
    al.tag = BACK_CANT_DELIVERY_SELECTION_TAG;
    [al show];
}

-(void)selectionBackCantDeliveryWithResumeDelivery
{
    if ([@"OFFICE" isEqualToString:self.currentOrder.returnDropoff])
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't deliver this order ?"
                                                    message:@"Please choose option below to complete !"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Call to Support",@"Return recipient is back,deliver to him",@"Return to Receiver",nil];
        al.tag = BACK_CANT_DELIVERY_SELECTION_WITH_RESUME_TAG;
        [al show];
    }
    else if([@"PICKUP_LOCATION" isEqualToString:self.currentOrder.returnDropoff]
            || [@"DESTINATION_LOCATION" isEqualToString:self.currentOrder.returnDropoff])
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't deliver this order ?"
                                                    message:@"Please choose option below to complete !"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Call to Support",@"Return recipient is back,deliver to him",@"Return to Office",nil];
        al.tag = BACK_CANT_DELIVERY_SELECTION_WITH_RESUME_TAG;
        [al show];
    }
    
}

-(void)selectionBackWait
{
    if (!isShowSelectionBackWait)
    {
        isShowSelectionBackWait = true;
        self.currentBackWaitAlert = [[UIAlertView alloc]initWithTitle:@"Do you want to wait for another 5 more minutes?"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Yes",nil];
        self.currentBackWaitAlert.tag = WAIT_SELECTION_TAG;
        [self.currentBackWaitAlert show];
    }
}

-(void)confirmCancelOrderWaitingSelection
{
    self.currentCancelOrderWaiting = [[UIAlertView alloc]initWithTitle:@"Are you sure you want to cancel this job?"
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"No"
                                      otherButtonTitles:@"Yes", nil];
    self.currentCancelOrderWaiting.tag = CONFIRM_CANCEL_ORDER_WAITING_SELECTION_TAG;
    [self.currentCancelOrderWaiting show];
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

-(void) showErrorMessageWhenCancelOrderWithReason {
    
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

- (void)backCancelOrderWithReason:(NSString*)reason note:(NSString*)note
{
    [HServiceAPI backCancelOrderCode:self.currentOrder.oid reason:reason note:note handler:^(NSDictionary *results, NSError *error) {
        if (error==nil)
        {
            [APPSHARE checkActiveOrder:NO];
            DLog("Preparing for come back Available orders...");
            [timerRefresh invalidate];
            timerRefresh = nil;
            [OOrderAvailable deleteAllOrder];
            [[WatchManager shared] completeOrder];
            [APPSHARE addLeftPanelwithOrder:nil];
        }
    }];
}

-(void)selectedResumeDelivery
{
    if ([self.currentOrder.returnDropoff isEqualToString:@"OFFICE"])
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Choose an Action"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Call Support",@"Recipient is back,deliver to him",@"Return to Sender",nil];
        al.tag = 9;
        [al show];
    }
    if([self.currentOrder.returnDropoff isEqualToString:@"PICKUP_LOCATION"])
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Choose an Action"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Call Support",@"Recipient is back,deliver to him",@"Return to Office",nil];
        al.tag = 9;
        [al show];
    }
}

-(void)selectedCantPickUp
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Choose an Action"
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Can't Pickup",@"Cancel this Order",nil];
    al.tag = 1;
    [al show];
}

-(void)CantPickupAlert
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

-(void)selectedNextOrder
{
    [HServiceAPI onCloseOrder:^(BOOL finish, NSError *error)
     {
         if (!error)
         {
             [APPSHARE checkActiveOrder:NO];
             NSLog(@"complete close order");
             [OOrderAvailable deleteAllOrder];
             [[WatchManager shared] completeOrder];
             [APPSHARE addLeftPanelwithOrder:nil];
             RELOAD_MENU_LEFT
         }
     }];
}

-(void)selectedCantDelivery
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"Are you sure you can't deliver this order ?"
                                                message:@"Please choose option below to complete !"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Call to Support",@"Return to Sender",@"Return to Office",nil];
    al.tag = 4;
    [al show];
}

- (void)cancelOrderWithReason:(NSString*)reason note:(NSString*)note
{
    [HServiceAPI cancelOrderWithId:self.currentOrder.oid reason:reason note:note handler:^(NSDictionary *results, NSError *error) {
        isShowSelectionBackWait = false;//ready show popup selection back waiting
        if (error==nil)
        {
            [APPSHARE checkActiveOrder:NO];
            [timerRefresh invalidate];
            timerRefresh = nil;
            [OOrderAvailable deleteAllOrder];
            [[WatchManager shared] completeOrder];
            [APPSHARE addLeftPanelwithOrder:nil];
        }
    }];
}

#pragma mark - DELEGATES

//MARK: - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //alert other actions
    if (alertView.tag==1)
    {
        if (buttonIndex==0)
        {
            DLog(@"cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"can't pickup");
            [self CantPickupAlert];
        }
        else if (buttonIndex==2)
        {
            DLog(@"cancel this order");
            [self CancelOrderAlert];
        }
    }
    //alert cant pickup
    else if(alertView.tag == 2)
    {
        if (buttonIndex==0)
        {
            DLog(@"Cancel");
        }
        else if (buttonIndex==1)
        {
            DLog(@"Call to Sender");
            [self makePhoneCall:self.currentOrder.phonePickup];
        }
        else if (buttonIndex==2)
        {
            DLog(@"Still can't Pick Up");
            [self cancelOrderWithReason:@"CANT_PICKUP" note:nil];
        }
        else if (buttonIndex == 3)
        {
            DLog(@"Problem Solved");
        }
    }
    //alert cancel this order
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
    //alert cant delivery
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
            DLog(@"Return to Sender")
            [self returnSenderOrOffice:@"CANT_DELIVER" destination:@"PICKUP_LOCATION"];
        }
        else if (buttonIndex==3)
        {
            DLog(@"Return to Office");
            [self returnSenderOrOffice:@"CANT_DELIVER" destination:@"OFFICE"];
        }
    }
    else  if (alertView.tag == WAIT_SELECTION_TAG && self.currentOrder.isReturnTrip)
    {//Selection after finish waiting time
        if (buttonIndex==0)
        {
            DLog(@"No button --> show alert confirm Cancel Order");
            [self confirmCancelOrderWaitingSelection];
        }
        else if (buttonIndex == 1)
        {
            DLog(@"Yes button --> Call to waitMore5Minutes method.....");
            [self waitMore5Minutes];
        }
    }
    else if (alertView.tag == BACK_CANT_DELIVERY_SELECTION_TAG && self.currentOrder.isReturnTrip)
    {//Back cant deliver
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
            //Return destination = DESTINATION_LOCATION - Reason = CANT_DELIVER
            DLog(@"Return to Receiver")
            [self returnReceiverOrOffice:@"CANT_DELIVER" destination:@"DESTINATION_LOCATION"];
        }
        else if (buttonIndex==3)
        {
            DLog(@"Return to Office");
            //Return destination = OFFICE - Reason = CANT_DELIVER
            [self returnReceiverOrOffice:@"CANT_DELIVER" destination:@"OFFICE"];
        }
        
    }
    else if (alertView.tag == BACK_CANT_DELIVERY_SELECTION_WITH_RESUME_TAG && self.currentOrder.isReturnTrip)
    {//Back cant deliver with resume option
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
            //Recipient is back, deliver to him
            DLog(@"Back Resume delivery");
            [self backResumeDelivery];
        }
        else if (buttonIndex==3)
        {
            //Return destination = DESTINATION_LOCATION - Reason = CANT_DELIVER
            DLog(@"Return to Receiver/OFFICE")
            if([@"OFFICE" isEqualToString:self.currentOrder.returnDropoff])
            {
                [self returnReceiverOrOffice:@"CANT_DELIVER" destination:@"DESTINATION_LOCATION"];
            }
            else
            {
                [self returnReceiverOrOffice:@"CANT_DELIVER" destination:@"OFFICE"];
            }
        }
    }
    else if (alertView.tag == CONFIRM_CANCEL_ORDER_WAITING_SELECTION_TAG && self.currentOrder.isReturnTrip) {
        if (buttonIndex==0)
        {
            DLog(@"Do not Cancel");
            isShowSelectionBackWait = false;
            [self selectionBackWait];
        }
        else if (buttonIndex==1)
        {
            DLog(@"Cancel order with reason");
            [self showPopupReasonCancelOrder];
            //[self showPopupReasonCancelOrder:self.currentOrder.state isReturnTrip:self.currentOrder.isReturnTrip];
        }
    }else if (alertView.tag == RE_ENTER_REASON_CANCELLATION_ORDER_TAG && self.currentOrder.isReturnTrip) {
        if (buttonIndex==0)
        {
            DLog(@"Re-enter reason Cancel order.....");
            [self showPopupReasonCancelOrder];
        }
    } else if (alertView.tag == CANCELLATION_ORDER_TAG)
    {
        if (buttonIndex == 0)
        {
            NSString *reasonContent = [self.reasonTextView.text stringRemoveSpace];

            if (reasonContent.length<1)
            {
                [self showErrorMessageWhenCancelOrderWithReason];
                //[UIAlertView showErrorWithMessage:@"Please enter your reason" handler:nil];
            }
            else
            {
                if (self.currentOrder.isReturnTrip && [stateValueWaiting isEqualToString:self.currentOrder.state])
                {
                    [self backCancelOrderWithReason:@"WAITING_TIMEOUT" note:reasonContent];
                }
                else
                {
                    //[self cancelOrderWithReason:(reasonContent.length>0)?@"OTHER":@"CANT_PICKUP" note:reasonContent];
                    [self cancelOrderWithReason:@"OTHER" note:reasonContent];
                }
            }
        }
        else if (buttonIndex==1)
        {
            if (self.currentOrder.isReturnTrip && [stateValueWaiting isEqualToString:self.currentOrder.state])
            {
                DLog(@"Deny to cancel");
                isShowSelectionBackWait = false;
                [self selectionBackWait];
            }
            
        }
    }
    else if (alertView.tag == 9)
    {
        if (buttonIndex == 0)
        {
            DLog(@"cancel");
        }
        else if (buttonIndex == 1)
        {
            DLog(@"Call Support");
            [self makePhoneCall:officePhone];
        }
        else if (buttonIndex == 2)
        {
            DLog(@"recipient is back");
            [self resumeDelivery];
        }
        else if (buttonIndex == 3)
        {
            DLog(@"Return to Office or sender");
            if ([self.currentOrder.returnDropoff isEqualToString:@"OFFICE"])
            {
                [self returnSenderOrOffice:@"CANT_DELIVER" destination:@"PICKUP_LOCATION"];
            }
            if ([self.currentOrder.returnDropoff isEqualToString:@"PICKUP_LOCATION"])
            {
                [self returnSenderOrOffice:@"CANT_DELIVER" destination:@"OFFICE"];
            }
        }
    }
}

//MARK: - VCCommentDelegate

- (void)didCommentWithReason:(NSString *)reason selected:(NSString *)selected{
    [self cancelOrderWithReason:selected note:reason];
}

//MARK: - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    
    NSString *strFinal = [textView.text stringByReplacingCharactersInRange:range withString:string];
//    NSString *state = self.currentOrder.state;
//    BOOL isReturnTrip = self.currentOrder.isReturnTrip;
    
//    DLog(@"shouldChangeTextInRange...state=%@,isReturnTrip=%s, strFinal.length=%lu", state, (isReturnTrip ? "YES" : "NO"), (unsigned long)strFinal.length);
    
    /*if([string isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }*/
    if (self.currentOrder.isReturnTrip && strFinal.length > reasonLength)
    {
        return NO;
    }
    return YES;
}

//MARK: - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *strFinal = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *state = self.currentOrder.state;
    BOOL isReturnTrip = self.currentOrder.isReturnTrip;
    
    DLog(@"shouldChangeCharactersInRange...state=%@,isReturnTrip=%s, strFinal=%@, string=%@", state, (isReturnTrip ? "YES" : "NO"), strFinal, string);
    
    if (strFinal.length == 0)
    {
        self.lbConfirmCodeNote.hidden = YES;
    }
    else
    {
        self.lbConfirmCodeNote.hidden = NO;
    }
    
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
        else if (!isReturnTrip && [state isEqualToString:stateKeyDelivery])
        {
            [self verifyDelivery];
        }
        else if ([stateKeyReturning isEqualToString:state])
        {
            [self returnSenderOrOfficeCode];
        }
        /**
         * Upgrades for return trip function
         */
        else if (isReturnTrip && [stateKeyDelivery isEqualToString:state])
        {
            [self waitingConfirm];
        }
        else if (isReturnTrip && [stateValueWaiting isEqualToString:state])
        {
            [self backPickUpConfirm];
        }
        else if (isReturnTrip && [stateKeyBackDelivery isEqualToString:state])
        {
            [self backDeliveryConfirm];
        }
        else if (isReturnTrip && [stateKeyBackReturning isEqualToString:state])
        {
            [self backReturnOrderCode];
        }
    }
    else if (strFinal.length == reasonLength)
    {
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.lbConfirmCodeNote.hidden = YES;
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.lbConfirmCodeNote.hidden = YES;
    
    [textField resignFirstResponder];
    return YES;
}

-(void)verifyDelivery
{
    [HServiceAPI confirmDeliveryCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Verify DeliveryCode Success");
             [APPSHARE checkActiveOrder:NO];
             [OOrderAvailable deleteAllOrder];
             [[WatchManager shared] completeOrder];
             [APPSHARE addLeftPanelwithOrder:nil];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

- (void)verifyPickUp
{
    [HServiceAPI confirmPickupCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Confirmed pickup code Successful");
             [self refreshOrder];
             [self stopTimer];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

-(void)returnSenderOrOffice:(NSString*)reason destination:(NSString*)destination
{
    [HServiceAPI cantDeliveryOrder:self.currentOrder.oid reason:reason destination:destination handler:^(NSDictionary *results, NSError *error)
     {
         if (error==nil)
         {
             [timerRefresh invalidate];
             timerRefresh = nil;
             [self refreshOrder];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

-(void)returnSenderOrOfficeCode
{
    [HServiceAPI returnSenderOrOfficeCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Return Sender or Office Success");
             [self refreshOrder];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

-(void)resumeDelivery
{
    [HServiceAPI onResumeDelivery:self.currentOrder.oid block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Resume Delivery");
             [self refreshOrder];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

/**
 * Upgrades for return trip function
 */
-(void)returnReceiverOrOffice:(NSString*)reason destination:(NSString*)destination
{
    [HServiceAPI backCantDeliveryOrderCode:self.currentOrder.oid reason:reason destination:destination handler:^(NSDictionary *results, NSError *error)
     {
         if (error==nil)
         {
             [timerRefresh invalidate];
             timerRefresh = nil;
             
             [self refreshOrder];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

-(void)backReturnOrderCode
{
    [HServiceAPI backReturnOrderCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"---->Back Return Order Successful");
             [self refreshOrder];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

/**
 * Using replace for /order/active/deliver/ API
 */
- (void)waitingConfirm
{
    NSLog(@"Confirmation delivery code when order is return trip.....");
    [HServiceAPI waitingOrderCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Confirmed waiting code Successful");
             [self refreshOrder];
             
         } else {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

- (void)backPickUpConfirm
{
    [HServiceAPI backPickUpOrderCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Confirmed back pickup code Success");
             [self refreshOrder];
             [self stopTimer];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

-(void)backDeliveryConfirm
{
    [HServiceAPI backDeliverOrderCode:code block:^(BOOL finish, NSError *error)
     {
         if (!error && finish)
         {
             NSLog(@"Verify Back deliver code Success");
             [APPSHARE checkActiveOrder:NO];
             [OOrderAvailable deleteAllOrder];
             [APPSHARE addLeftPanelwithOrder:nil];
             [[WatchManager shared] completeOrder];
         }
         else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}

-(void)backResumeDelivery
{
    [HServiceAPI backResumeDeliveryOrderCode:^(BOOL finish, NSError *error)
     {
         if (!error)
         {
             NSLog(@"Back resume delivery successful");
             [self refreshOrder];
             
         } else
         {
             [self errorHandler:error];
         }
         self.tfConfirmCode.text = @"";
         self.lbConfirmCodeNote.hidden = YES;
         [self.tfConfirmCode resignFirstResponder];
     }];
}


//----- Time handler

-(void)waitMore5Minutes
{
    [HServiceAPI postWaiting:^(BOOL finish, NSError *error)
     {
         isShowSelectionBackWait = false;
         if (!error && finish)
         {
             [self waitingTimeHandler:YES];
         }
         else
         {
             [self errorHandler:error];
             [self selectionBackWait];
         }
     }];
}

- (void)waitingTimeHandler:(BOOL)animated
{
    if ((self.waitingTimer != nil && self.waitingTimer.isValid && secondsUntilFinished > 0)) return;
    if (self.currentOrder != nil && (!self.currentOrder.isReturnTrip
                                     || (self.currentOrder.isReturnTrip && ![stateValueWaiting isEqualToString:self.currentOrder.state]) )) return;
    
    [HServiceAPI getWaitingTime:^(NSDictionary *results, NSError *error)
     {
         if (!error)
         {
             if([results objectForKey:@"latest_waiting_time"] && [results objectForKey:@"time_total"]
                && [results objectForKey:@"time_remaining"]) {
                 
                 NSString *latestWaitingTime = [results stringForKey:@"latest_waiting_time"];
                 int secondWaitingTotal = [[results stringForKey:@"time_total"] intValue];
                 int secondRemaining = [[results stringForKey:@"time_remaining"] intValue];
                 
                 if (secondRemaining > 0 && secondWaitingTotal > 0 && ![Util isNullOrNilObject:latestWaitingTime]) {
                     long long latestWaitingTimeLong = [NSDate getTimeLongFromTimeString:latestWaitingTime :@"UTC+00:00" :@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z"];
                     
                     [self waitingCountDownViaServerHandler:secondWaitingTotal secondRemaining:secondRemaining latestWaitingTime: latestWaitingTimeLong animated:animated];
                     
                     [AuthManager saveWaitingTimeTotal:secondWaitingTotal];
                     [AuthManager saveTimeRemainingSecond:secondRemaining];
                     [AuthManager saveLatestWaitingTime:latestWaitingTimeLong];
                 }
                 else
                 {
                     [self.waitingProgressView setProgress:1.0f animated:NO];
                     self.waitingProgressView.progressLabel.text = @"00:00";
                     //Show popup waiting: Wait 5 more minutes & Cancel order Option
                     [self selectionBackWait];
                 }
                 
             }
             else
             {
                 [self.view makeToast:@"Can't connect to server"];
             }
         }
         else
         {
             [self errorHandler:error];
         }
     }];
}

-(void)waitingCountDownViaServerHandler:(int)secondsWaitingTime secondRemaining:(int) secondRemaining latestWaitingTime:(long long)latestWaitingTime animated:(BOOL)animated {
    
    if ((self.waitingTimer != nil && self.waitingTimer.isValid && secondsUntilFinished > 0) || isShowSelectionBackWait) return;
    
    //reset progress percent equals zero
    self.waitingProgressView.progress = 0.0f;
    
    secondsWaitingTotal = secondsWaitingTime;
    secondsUntilFinished = secondRemaining;
    
    NSLog(@"---Start new countdown timer.secondsWaitingTotal=%d,secondsUntilFinished=%d,latestWaitingTime=%lld", secondsWaitingTotal, secondsUntilFinished, latestWaitingTime);
    
    if (secondsUntilFinished > 0) {
        int ani = (animated ? 1 : 0);
        NSDictionary *dictAnimated = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:ani], @"animated", nil];
        
        self.waitingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runScheduledTask:) userInfo:dictAnimated repeats:YES];
    } else {
        [self.waitingProgressView setProgress:1.0f animated:NO];
        self.waitingProgressView.progressLabel.text = @"00:00";
    }
    //-----------------------------------------------------------------------//
}

- (void)stopTimer {
    if (self.waitingTimer != nil) {
        [self.waitingTimer invalidate];
        self.waitingTimer = nil;
    }
    [self.waitingProgressView setProgress:1.0f animated:NO];
    self.waitingProgressView.progressLabel.text = @"00:00";
    secondsUntilFinished = 0;
}

- (void)runScheduledTask: (NSTimer *) runningTimer {
    
    if (secondsUntilFinished > 0) {
        secondsUntilFinished--;
        BOOL animated = YES;
        if (runningTimer && [runningTimer userInfo] != nil && [[runningTimer userInfo] objectForKey:@"animated"]) {
            int ani = [[[runningTimer userInfo] objectForKey:@"animated"] intValue];
            animated = (ani == 1 ? YES:NO);
        }
        
        //int _freeHours = secondsUntilFinished / 3600;
        int _freeMinutes = (secondsUntilFinished % 3600) / 60;
        int freeSeconds = (secondsUntilFinished % 3600) % 60;
        
        //recalculate progress percent
        int secondsPassed = secondsWaitingTotal - secondsUntilFinished;
        CGFloat progress = ((secondsPassed * 1.0f)/(secondsWaitingTotal * 1.0f));// * 100;
        
        [self.waitingProgressView setProgress:progress animated:animated];
        
        NSLog(@"secondsUntilFinished=%d, _freeMinutes=%d, secondsPassed=%d,progress=%f, waitingTimer.isValid=%s", secondsUntilFinished, _freeMinutes, secondsPassed, progress,(self.waitingTimer.isValid ? "YES" : "NO"));
        
        if (self.waitingProgressView.progress >= 1.0f && [self.waitingTimer isValid]) {
            [self.waitingProgressView setProgress:1.0f animated:NO];
            [self stopTimer];
            
            //Show popup waiting: Wait 5 more minutes & Cancel order Option
            [self selectionBackWait];
        }
        
        self.waitingProgressView.progressLabel.text = [NSString stringWithFormat:@"%02d:%02d", _freeMinutes, freeSeconds];
        
        ///--------------------------------//
        
    } else {
        [self.waitingProgressView setProgress:1.0f animated:NO];
        self.waitingProgressView.progressLabel.text = @"00:00";
        NSLog(@"--->secondsUntilFinished <= 0");
        [self stopTimer];
        //Show popup waiting: Wait 5 more minutes & Cancel order Option
        [self selectionBackWait];
    }
}

- (NSString *)calculatorTimerStart:(OOrderAvailable *)currentOrder {
    if (currentOrder == nil) return @"00:00";
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    NSString *timerStartedString = [format stringFromDate:currentOrder.timeStart];
    NSLog(@"timerStartedString=%@", timerStartedString);
    
    if (![Util isNullOrNilObject:timerStartedString]) {
        long long timerStarted = [NSDate getTimeLongFromTimeString:timerStartedString :@"UTC" :@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        //London - United Kingdom
        long long todayTimeSeconds = [NSDate getTodayTimeSeconds:@"UTC" :@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];//yyyy-MM-dd'T'HH:mm:ss.SSS'Z
        
        long long diff = todayTimeSeconds - timerStarted;
        
        if (diff > 0) {
            int _freeHours = (int)(diff / 3600);
            int _freeMinutes = (int)((diff % 3600) / 60);
            
            return [NSString stringWithFormat:@"%02d:%02d", _freeHours, _freeMinutes];
        }
    }
    return @"00:00";
}

@end