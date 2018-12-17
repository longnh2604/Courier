//
//  OrderHelper.m
//  Delivery
//
//  Created by Long Nguyen on 1/8/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OrderHelper.h"

@implementation OrderHelper

+ (BOOL)isShowConfirmCode:(OOrderAvailable*)order{
    NSString *code = [self showConfirmCodeWithStatus:order];
    if (code.length>0) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSString*)showConfirmCodeWithStatus:(OOrderAvailable*)order{
    DLog(@"state = %@",order.state);
    if ([order.state isEqualToString:stateKeyAccepted]) {
        return [NSString stringWithFormat:@"Pick-up confirmation: %@",order.pickupConfirmCode];
        
    }else if([order.state isEqualToString:stateKeyDelivery]){
        return [NSString stringWithFormat:@"Drop-off confirmation: %@",order.dropoffConfirmCode];
        
    }else if([order.state isEqualToString:stateKeyReturning]){
        
        if ([order.returnDropoff isEqualToString:@"OFFICE"]){
            return [NSString stringWithFormat:@"Courier can't contact you"];
        }else{
            return [NSString stringWithFormat:@"Return confirmation: %@",order.dropoffConfirmCode];
        }
        
    }else if ([order.state isEqualToString:stateKeyInOffice]){
        return [NSString stringWithFormat:@"Order #%@ was delivered to office",order.oid];
    }else{
        return @"";
    }
}
+ (NSString*)showNoteConfirmCode:(OOrderAvailable*)order{
    if ([order.state isEqualToString:stateKeyAccepted]) {
        return @"Please show it to the courier";
    }else if([order.state isEqualToString:stateKeyDelivery]){
        return @"This code was sent to receiver via SMS";
    }else if([order.state isEqualToString:stateKeyReturning]){
        
        if ([order.state isEqualToString:@"OFFICE"]){
            return [NSString stringWithFormat:@"Courier will deliver order #%@ to our office",order.oid];
        }else{
            return @"Please show it to courier to get the order";
        }
    }else if ([order.state isEqualToString:stateKeyInOffice]){
        if (order.resolutionNote.length>0) {
            return order.resolutionNote;
        }else{
            return @"Courier is olen";
        }
    }else{
        return @"";
    }
}

+ (BOOL)isShowTimerDelivering:(OOrderAvailable*)order
{
    if ([order.state isEqualToString:stateKeyDelivery] || [stateKeyBackDelivery isEqualToString:order.state] || [stateValueWaiting isEqualToString:order.state] || [stateKeyAdminCancelled isEqualToString:order.state] || [stateKeyBackReturned isEqualToString:order.state] || [stateKeyBackReturning isEqualToString:order.state] || [stateKeyCancelled isEqualToString:order.state] || [stateKeyInOffice isEqualToString:order.state] || [stateKeyReturned isEqualToString:order.state] || [stateKeyReturning isEqualToString:order.state]) {
        
        return YES;
    }else{
        return NO;
    }
}

+ (NSString*)calculatorTimerStart:(OOrderAvailable*)order
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval start = [order.timeStart timeIntervalSince1970];
    double deltaSeconds = now - start;
    double deltaMinutes = floor(deltaSeconds / 60.0f);
    double deltaHours = floor(deltaMinutes / 60.0f);
    
    NSString *strMinutes,*strHours;
    double m = deltaMinutes-(deltaHours*60);
    if (m>0) {
        if (m<10) {
            strMinutes = [NSString stringWithFormat:@"0%.f",m];
        }else{
            strMinutes = [NSString stringWithFormat:@"%.f",m];
        }
    }else{
        strMinutes = @"00";
    }
    if (floor(deltaHours)<10) {
        strHours = [NSString stringWithFormat:@"0%.f",floor(deltaHours)];
    }else{
        strHours = [NSString stringWithFormat:@"%.f",floor(deltaHours)];
    }
    return [NSString stringWithFormat:@"%@:%@",strHours,strMinutes];
}

+ (BOOL)checkNeedRefreshOrder:(OOrderAvailable*)order{
    if ([order.state isEqualToString:stateKeyCompleted] ||
        [order.state isEqualToString:stateKeyCourierCancelled] ||
        [order.state isEqualToString:stateKeyAdminCancelled] ||
        [order.state isEqualToString:stateKeyCancelled] ||
        [order.state isEqualToString:stateKeyInOffice])
    {
        DLog(@"order state %@",order.state);
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)checkHiddenAllButton:(OOrderAvailable*)order history:(BOOL)history{
    if (history==YES) {
        return YES;
    }else{
        if ([order.state isEqualToString:stateKeyDelivery]) {
            return YES;
        }else{
            return NO;
        }
    }
}

@end
