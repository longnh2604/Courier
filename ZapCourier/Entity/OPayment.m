//
//  OPayment.m
//  Delivery
//
//  Created by Long Nguyen on 1/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OPayment.h"

@implementation OPayment


+ (OPayment*)convertObject:(NSDictionary*)object{
    OPayment *pay = [[OPayment alloc]init];
    pay.bin = [object stringForKey:@"bin"];
    pay.cardType = [object stringForKey:@"card_type"];
    pay.cardHolderName = [object stringForKey:@"cardholder_name"];
    pay.cardDefault = [object stringForKey:@"default"];
    pay.expirationMonth = [object stringForKey:@"expiration_month"];
    pay.expirationYear = [object stringForKey:@"expiration_year"];
    pay.expired = [object stringForKey:@"expired"];
    pay.imageUrl = [object stringForKey:@"image_url"];
    pay.last4 = [object stringForKey:@"last_4"];
    pay.maskedNumber = [object stringForKey:@"masked_number"];
    pay.token = [object stringForKey:@"token"];
    
    return pay;
}

+ (BOOL)checkExpired:(OPayment*)payment{
    if (payment.expirationMonth==nil || payment.expirationYear==nil) {
        return NO;
    }
    DLog(@"month = %@ --- year = %@",payment.expirationMonth,payment.expirationYear);
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:units fromDate:now];
    
    if (payment.expirationYear.integerValue > components.year) {
        return NO;
    }else if (payment.expirationYear.integerValue == components.year){
        if (payment.expirationMonth.integerValue >= components.month) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }

}

@end
