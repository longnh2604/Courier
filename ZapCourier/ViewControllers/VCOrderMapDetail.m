//
//  VCOrderMapDetail.m
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "VCOrderMapDetail.h"

@interface VCOrderMapDetail ()

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation VCOrderMapDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.pkd.geleximco@gmail.com
    if (self.isBulk)
    {
        [self configMapBulk];
    }else
    {
        [self configMapSingle];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - LAYOUT

- (void)configMapSingle
{
    [self.mapView clear];
//    self.mapView.myLocationEnabled = YES;
//    self.mapView.settings.myLocationButton = YES;
    
    //marker
    
    
    if (self.isNotShowDropOff==NO) {
        GMSMarker *dropoff = [GMSMarker markerWithPosition:self.dropOffLocation];
        dropoff.map = _mapView;
        dropoff.icon = [UIImage imageNamed:@"dropOff"];
        dropoff.title = self.dropOffAddress;
        dropoff.groundAnchor = CGPointMake(0.5, 1);
    }else{
        GMSMarker *pickup = [GMSMarker markerWithPosition:self.pickUpLocation];
        pickup.map = _mapView;
        pickup.icon = [UIImage imageNamed:@"pickUp"];
        pickup.title = self.pickUpAddress;
        pickup.groundAnchor = CGPointMake(0.5, 1);
    }
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]init];
    
    GMSMarker *pin = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    pin.map = _mapView;
    pin.icon = [UIImage imageNamed:@"PinCourier"];
    pin.title = @"My location";
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    
    if (self.isNotShowDropOff==NO){
        bounds = [bounds includingCoordinate:self.dropOffLocation];
    }else{
        bounds = [bounds includingCoordinate:self.pickUpLocation];
    }
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(100, 50, 50, 50)];
    [self.mapView animateWithCameraUpdate:update];
}

- (void)configMapBulk{
    [self.mapView clear];
//    self.mapView.myLocationEnabled = YES;
//    self.mapView.settings.myLocationButton = YES;
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]init];
    
    //marker pickup
    GMSMarker *markerPickup = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.bulkJobs.pickUpLat, self.bulkJobs.pickUpLon)];
    markerPickup.map = _mapView;
    markerPickup.title = self.bulkJobs.pickUpAddress;
    markerPickup.icon = [UIImage imageNamed:@"pickUp"];
    markerPickup.groundAnchor = CGPointMake(0.5, 1);
    
    bounds = [bounds includingCoordinate:markerPickup.position];
    
    //marker drop-off
    for (OOrderAvailable *o in self.bulkJobs.arOrders) {
        if ([self.bulkJobs.state isEqualToString:stateKeyCompleted] || [self.bulkJobs.state isEqualToString:stateKeyInOffice] || [self.bulkJobs.state isEqualToString:stateKeyReturned])
        {
            //not add
        }
        else
        {
            GMSMarker *markerDropOff = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon)];
            markerDropOff.map = _mapView;
            markerDropOff.icon = [UIImage imageNamed:@"dropOff"];
            markerDropOff.groundAnchor = CGPointMake(0.5, 1);
            markerDropOff.title = o.dropoffAddress;
            bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(o.dropOffLat, o.dropOffLon)];
        }
        
    }
    
    //marker courier
    GMSMarker *pin = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(APPSHARE.tempLate, APPSHARE.tempLong)];
    pin.map = _mapView;
    pin.icon = [UIImage imageNamed:@"PinCourier"];
    pin.title = @"My location";
    pin.groundAnchor = CGPointMake(0.5, 1);
    
    bounds = [bounds includingCoordinate:pin.position];
    
    //update camera
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(100, 50, 50, 50)];
    [self.mapView animateWithCameraUpdate:update];
}

@end
