//
//  VCAcceptJobs.m
//  ZapCourier
//
//  Created by Long Nguyen on 3/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCAcceptJobs.h"

#import "PickUpCell.h"
#import "DropOffCell.h"
#import "PackageCell.h"
#import "SenderCell.h"
#import "AcceptCell.h"
#import "VCOrderBulkAssign.h"
#import "VCSender.h"
#import "VCAvailableOrder.h"

@interface VCAcceptJobs ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    UIAlertView *alert;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTbView;

@property (weak, nonatomic) IBOutlet UIScrollView *scView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContent;

@end

@implementation VCAcceptJobs

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLayout];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"Order #B%@",self.bulkJobs.bid];
}

#pragma mark - LAYOUT

- (void)setLayout{
    
    self.heightContent.constant = [self heightOfContentSize];
    self.heightTbView.constant = [self calculatorHeightOfTableView];
    
    [self.view updateConstraintsIfNeeded];
    
    [self showMarker];
}

- (void)showMarker{
    [self.mapView clear];
    self.mapView.settings.rotateGestures = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.scrollGestures = NO;
    self.mapView.settings.zoomGestures = NO;
    [self.mapView.settings setAllGesturesEnabled:NO];
    self.mapView.settings.consumesGesturesInView = YES;
    self.mapView.userInteractionEnabled = NO;
    
    //marker
    GMSMarker *markerPickup = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.bulkJobs.pickUpLat, self.bulkJobs.pickUpLon)];
    markerPickup.map = _mapView;
    markerPickup.icon = [UIImage imageNamed:@"pickUp"];
    markerPickup.groundAnchor = CGPointMake(0.5, 1);
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]init];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(self.bulkJobs.pickUpLat, self.bulkJobs.pickUpLon)];
    
    for (OOrderAvailable *o in self.bulkJobs.arOrders) {
        GMSMarker *markerDropOff = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon)];
        markerDropOff.map = _mapView;
        markerDropOff.icon = [UIImage imageNamed:@"dropOff"];
        markerDropOff.groundAnchor = CGPointMake(0.5, 1);
        
        bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon)];
    }
    
    GMSMarker *pin = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    pin.map = _mapView;
    pin.icon = [UIImage imageNamed:@"PinCourier"];
    pin.groundAnchor = CGPointMake(0.5, 1);
    
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(50, 20, 0, 20)];
    [self.mapView animateWithCameraUpdate:update];
}

#pragma mark - FUNCTIONS

//MARK: - Calculator height
- (float)calculatorHeightOfTableView{
    CGFloat height;
    for (OOrderAvailable *order in self.bulkJobs.arOrders) {
//        DLog(@"height = %f",[order.dropoffAddress heightWithFont:[UIFont systemFontOfSize:12] forWidth:(SCREEN_WIDTH-47)]);
        height += [order.dropoffAddress heightWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] forWidth:(SCREEN_WIDTH-47)] + 36 + 6;
    }
    /////// pickup + package + sender + accept + dropoff
    return  108 + 110 + 135 + 80 + height;
}

- (float)heightOfContentSize{
    return [self calculatorHeightOfTableView] + 270;
}

#pragma mark - ACTIONS

- (void)selectedAcceptButton:(UIButton*)button{
    [HServiceAPI acceptBulkOrderWithId:self.bulkJobs.bid handler:^(NSDictionary *results, NSError *error)
    {
        if (error)
        {
            //DLog(@"error = %@",error);
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
                        NSString *msg = [NSString stringWithFormat:@"Order #%@ has been cancelled or taken by others !",self.bulkJobs.bid];
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
        else
        {
            [APPSHARE checkActiveOrder:YES];
            [OUserLogin updateBulkOrder:self.bulkJobs.bid];
            [HServiceAPI getCurrentActiveBulkOrder:^(NSDictionary *results, NSError *error) {
                if (!error)
                {
                    RELOAD_MENU_LEFT
                    OBulk *o = [OBulk convertToObject:results];
                    [OBulk saveOrder:o];
                    [APPSHARE addLeftPanelwithBulkOrder:o];
                }
            }];
        }
    }];
}

#pragma mark - DELEGATES

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bulkJobs.arOrders.count+4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 108;
    }else if (indexPath.row>0 && indexPath.row<=self.bulkJobs.arOrders.count){
        
        OOrderAvailable *order = self.bulkJobs.arOrders[indexPath.row-1];
        return [order.dropoffAddress heightWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] forWidth:(SCREEN_WIDTH-47)] + 36 + 6;
//        return 57;
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+1)){
        return 110;
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+2)) {
        return 135;
    }else{
        return 80;
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 108;
    }else if (indexPath.row>0 && indexPath.row<=self.bulkJobs.arOrders.count){
        return 57;
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+1)){
        return 110;
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+2)) {
        return 135;
    }else{
        return 80;
    }
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        PickUpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickUpCell" forIndexPath:indexPath];
        
        cell.lbAddress.text = self.bulkJobs.pickUpAddress;
        
        return cell;
    }else if (indexPath.row>0 && indexPath.row<=self.bulkJobs.arOrders.count) {
        DropOffCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropOffCell" forIndexPath:indexPath];
        
        OOrderAvailable *o = self.bulkJobs.arOrders[indexPath.row-1];
        cell.lbOrderId.text = [NSString stringWithFormat:@"Order #%@",o.oid];
        cell.lbNumber.text = [NSString stringWithFormat:@"%d",(int)indexPath.row];
        cell.lbAddress.text = o.dropoffAddress;
        
        return cell;
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+1)) {
        PackageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PackageCell" forIndexPath:indexPath];
        
        cell.lbNote.text = self.bulkJobs.note;
        cell.lbPrice.text = self.bulkJobs.price;
        cell.lbPackage.text = @"PARCELS";
        cell.imvNote.hidden = (self.bulkJobs.note.length>0)?NO:YES;
        
        return cell;
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+2)) {
        SenderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SenderCell" forIndexPath:indexPath];
        
        cell.lbName.text = self.bulkJobs.senderName;
        [cell.imvAvatar sd_setImageWithURL:[NSURL URLWithString:self.bulkJobs.senderAvatar] placeholderImage:avatarPlaceHolder];
        
        return cell;
    }else{
        AcceptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AcceptCell" forIndexPath:indexPath];
        
        [cell.btnAccept addTarget:self action:@selector(selectedAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        //pickup cell
    }else if (indexPath.row>0 && indexPath.row<=self.bulkJobs.arOrders.count) {
        //dropoff cell
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+1)) {
        //package cell
    }else if (indexPath.row==(self.bulkJobs.arOrders.count+2)) {
        //sender cell -> chưa accept thì không xem được
    }else{
        //accept button cell
    }
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
