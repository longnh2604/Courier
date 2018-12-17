//
//  VCOrderMapDetail.h
//  ZapCourier
//
//  Created by Long Nguyen on 1/11/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCOrderMapDetail : BaseView

@property (nonatomic, assign) BOOL isBulk;
@property (nonatomic, assign) BOOL isNotShowDropOff;
@property (nonatomic, strong) OBulk *bulkJobs;
@property (nonatomic, strong) OOrderAvailable *currentOrder;

@property (nonatomic, assign) CLLocationCoordinate2D pickUpLocation;
@property (nonatomic, strong) NSString *pickUpAddress;
@property (nonatomic, assign) CLLocationCoordinate2D dropOffLocation;
@property (nonatomic, strong) NSString *dropOffAddress;



@end
