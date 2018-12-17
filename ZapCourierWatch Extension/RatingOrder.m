//
//  RatingOrder.m
//  Delivery
//
//  Created by Long Nguyen on 4/29/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "RatingOrder.h"

@interface RatingOrder (){
    int rate;
}

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *lbRate;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *btnTru;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *btnCong;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *btnSubmit;


@end

@implementation RatingOrder

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setTitle:@"Rating"];
    rate = 1;
    [self setRateToLabel];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setRateToLabel{
    [self.lbRate setText:[NSString stringWithFormat:@"%d",rate]];
}

- (IBAction)selectedTruButton {
    if (rate>1) {
        rate--;
        [self setRateToLabel];
    }
}

- (IBAction)selectedCongButton {
    if (rate<5) {
        rate++;
        [self setRateToLabel];
    }
}
- (IBAction)selectedSubmitButton {
    [self popController];
}

@end



