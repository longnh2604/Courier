//
//  VCOrderAvailableDetail.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCOrderAvailableDetail.h"
#import "LabelColor.h"
#import "DefaultButton.h"
#import "VCOrderAssign.h"
#import "VCOrderMapDetail.h"
#import "VCAvailableOrder.h"

@interface VCOrderAvailableDetail ()<UIAlertViewDelegate>{
    NSTimer *timerDelivering;
    NSTimer *timerRefresh;
    UIAlertView *alert;
}

@property (weak, nonatomic) IBOutlet UIView *scView;
@property (weak, nonatomic) IBOutlet UIView *viewMapDetail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContentScView;

@property (weak, nonatomic) IBOutlet UILabel *lbState;

@property (weak, nonatomic) IBOutlet UIView *vState;
@property (weak, nonatomic) IBOutlet UIView *vTwoWays;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewTwoWays;
@property (weak, nonatomic) IBOutlet UILabel *lbPickupAdd;
@property (weak, nonatomic) IBOutlet UILabel *lbDropoffAdd;

@property (weak, nonatomic) IBOutlet UIView *tfDetail;
@property (weak, nonatomic) IBOutlet UIView *vButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightViewButton;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet DefaultButton *btnTakeOrder;

@property (weak, nonatomic) IBOutlet UILabel *lbPickUpAddress;

@property (weak, nonatomic) IBOutlet UILabel *lbDropOffAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbDeliveryType;

@property (weak, nonatomic) IBOutlet UIImageView *imvPackage;
@property (weak, nonatomic) IBOutlet UILabel *lbSize;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbNote;

@property (weak, nonatomic) IBOutlet UIImageView *imvLineDash;

@end

@implementation VCOrderAvailableDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.hidesBackButton = YES;
    [self configMap];
    [self setLayout];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeStatusOrder" object:nil];
    [timerDelivering invalidate];
    timerDelivering = nil;
    [timerRefresh invalidate];
    timerRefresh = nil;
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
    
    GMSMarker *pin = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    pin.map = _mapView;
    pin.icon = [UIImage imageNamed:@"PinCourier"];
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]init];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(self.currentOrder.pickUpLat, self.currentOrder.pickUpLon)];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(self.currentOrder.dropOffLat, self.currentOrder.dropOffLon)];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(130, 20, 20, 20)];
    [self.mapView animateWithCameraUpdate:update];
    
    UITapGestureRecognizer *onMapDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickMap:)];
    [self.viewMapDetail addGestureRecognizer:onMapDetail];
}

- (void)onClickMap:(UITapGestureRecognizer*)sender
{
//    VCOrderMapDetail *order = VCORDER(VCOrderMapDetail);
//    order.currentOrder = self.currentOrder;
//    [self.navigationController pushViewController:order animated:YES];
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
    self.lbNote.text = self.currentOrder.note;
    
    self.lbPickupAdd.text = self.currentOrder.pickupAddressDetail;
    self.lbDropoffAdd.text = self.currentOrder.dropoffAddressDetail;
    
    [self.btnTakeOrder addTarget:self action:@selector(onTakeOrder) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)onTakeOrder
{
    [OOrderAvailable deleteAllOrder];
    [HServiceAPI acceptOrder:self.currentOrder.oid hander:^(NSDictionary *results, NSError *error)
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
                     [OOrderAvailable saveOrder:o];
                     [[WatchManager shared] sendStatusOrder:o];
                     [APPSHARE addLeftPanelwithOrder:o];
                 }
             }];
        }
        else
        {
            id jsonResponse = [HServiceAPI convertToJson:error.userInfo];
            //[error localizedDescription]
            
            if (jsonResponse)
            {
                if ([[jsonResponse objectForKey:@"code"]isEqualToString:@"new_token_required"])
                {
                    [[AuthManager shared] logout];
                    [APPSHARE showLogin];
                }
                if ([[jsonResponse objectForKey:@"detail"]isEqualToString:@"Not found"])
                {
                    if (alert==nil) {
                        NSString *msg = [NSString stringWithFormat:@"Order #%@ has been cancelled or taken by others !",self.currentOrder.oid];
                        alert = [[UIAlertView alloc]initWithTitle:@"Notice"
                                                          message:msg
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }
        }
    }];
}
//MARK: - AlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView==alert) {
        alert = nil;
        VCAvailableOrder *vc = VCAVAILABEL(VCAvailableOrder);
        [self showCenterView:vc];
    }
}
@end
