//
//  WATableRow.h
//  ZapCourier
//
//  Created by Long Nguyen on 2/1/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface WATableRow : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *rowTitle;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *rowCost;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *rowPickUp;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *rowDropOff;

@end
