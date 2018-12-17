//
//  OrderAssignWAController.m
//  ZapCourier
//
//  Created by Long Nguyen on 2/3/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OrderAssignWAController.h"
#import "Constant.h"
#import "Macros.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface OrderAssignWAController ()<WCSessionDelegate>

@end

@implementation OrderAssignWAController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setLayoutWithMessage:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        [[WCSession defaultSession] sendMessage:@{@"action":@"checkOrder"}
                                   replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
                                       NSLog(@"error = %@",error.localizedDescription);
                                   }];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setLayoutWithMessage:(NSDictionary*)message
{
    if (message)
    {
        NSString *action = [message objectForKey:@"action"];
        if ([action isEqualToString:@"completed"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"InterfaceController"] contexts:nil];
        }
        else if ([action isEqualToString:@"login"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"OrderAvailableWAController"] contexts:nil];
        }else if ([action isEqualToString:@"nonLogin"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"SplashWAController"] contexts:nil];
        }
        else
        {
            self.objMessage = message;
            [self setTitle:[NSString stringWithFormat:@"#%@",[message objectForKey:@"orderId"]]];
            [self.lbName setText:[NSString stringWithFormat:@"%@",[message objectForKey:@"senderName"]]];
            [self.lbCode setText:[NSString stringWithFormat:@"%@",[message objectForKey:@"senderPhone"]]];
            [self changeOrderTextStatus:[message objectForKey:@"orderState"]withDropoff:[message objectForKey:@"destination"]];
            [self changeStatusBackgroundWithStatus:[message objectForKey:@"orderState"]];
            
            NSString *avt = [message objectForKey:@"senderAvatar"];
            if (avt.length>0)
            {
                UIImage *img = [UIImage imageWithData:[[NSData alloc]initWithBase64EncodedString:avt options:NSDataBase64DecodingIgnoreUnknownCharacters]];
                [self.imvAvatar setImage:img];
            }
            else
            {
                [self.imvAvatar setImage:avatarPlaceHolder];
            }
        }
    }
}

- (IBAction)onCloseOrCallButton
{
    NSString *status = [self.objMessage objectForKey:@"orderState"];
    if ([status isEqualToString:stateKeyCompleted] ||
        [status isEqualToString:stateKeyReturned] ||
        [status isEqualToString:stateKeyBackReturned] ||
        [status isEqualToString:stateKeyInOffice] ||
        [status isEqualToString:stateKeyAdminCancelled])
    {
        [[WCSession defaultSession] sendMessage:@{@"action":@"next"} replyHandler:nil errorHandler:^(NSError * _Nonnull error)
         {
             NSLog(@"error = %@",error.localizedDescription);
         }];
    }else{
        [[WCSession defaultSession] sendMessage:@{@"action":@"call",
                                                  @"phone":[self.objMessage objectForKey:@"senderPhone"]}
                                   replyHandler:nil errorHandler:^(NSError * _Nonnull error)
        {
                                       NSLog(@"error = %@",error.localizedDescription);
                                   }];
    }
}

- (void)changeOrderTextStatus:(NSString*)status withDropoff:(NSString*)dropoff
{
    if ([status isEqualToString:stateKeyAccepted])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",statevalueAccepted]];
    }
    else if ([status isEqualToString:stateKeyDelivery])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueDelivery]];
    }
    else if ([status isEqualToString:stateKeyReturning])
    {
        if ([dropoff isEqualToString:@"PICKUP_LOCATION"])
        {
            [self.lbOrderStatus setText:[NSString stringWithFormat:@"RETURNING TO SENDER"]];
        }
        if ([dropoff isEqualToString:@"OFFICE"])
        {
            [self.lbOrderStatus setText:[NSString stringWithFormat:@"RETURNING TO OFFICE"]];
        }
    }
    else if ([status isEqualToString:stateKeyReturned])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueReturned]];
    }
    else if ([status isEqualToString:stateKeyWaiting])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueWaiting]];
    }
    else if ([status isEqualToString:stateKeyBackDelivery])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueBackDelivery]];
    }
    else if ([status isEqualToString:stateKeyBackReturning])
    {
        if ([dropoff isEqualToString:@"OFFICE"])
        {
            [self.lbOrderStatus setText:[NSString stringWithFormat:@"RETURNING TO OFFICE"]];
        }
        if ([dropoff isEqualToString:@"DESTINATION_LOCATION"])
        {
            [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueBackReturning]];
        }
    }
    else if ([status isEqualToString:stateKeyBackReturned])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueBackReturned]];
    }
    else if ([status isEqualToString:stateKeyInOffice])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueInOffice]];
    }
    else if ([status isEqualToString:stateKeyBackFailure])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueBackFailure]];
    }
    else if ([status isEqualToString:stateKeyAdminCancelled])
    {
        [self.lbOrderStatus setText:[NSString stringWithFormat:@"%@",stateValueAdminCancelled]];
    }
}

- (void)changeStatusBackgroundWithStatus:(NSString*)status
{
    if ([status isEqualToString:stateKeyAccepted])
    {
        //mau vang : d8a10b
        [self.groupStatus setBackgroundColor:UIColorFromRGB(0xd8a10b)];
        [self.btnCall setTitle:@"Call Sender"];
    }
    else if ([status isEqualToString:stateKeyCancelled] ||
              [status isEqualToString:stateKeyBackFailure] ||
              [status isEqualToString:stateKeyCourierCancelled]) {
        //red : ff0000
        [self.groupStatus setBackgroundColor:UIColorFromRGB(0xff0000)];
        [self.btnCall setTitle:@"Call Sender"];
    }
    else if ([status isEqualToString:stateKeyCompleted] ||
              [status isEqualToString:stateKeyReturned] ||
              [status isEqualToString:stateKeyBackReturned] ||
              [status isEqualToString:stateKeyInOffice] ||
              [status isEqualToString:stateKeyAdminCancelled]) {
        //mau xanh : 0x29b6f6
        [self.groupStatus setBackgroundColor:UIColorFromRGB(0x29b6f6)];
        [self.btnCall setTitle:@"Next Order"];
    }
    else if ([status isEqualToString:stateKeyDelivery] ||
              [status isEqualToString:stateKeyBackDelivery] ||
              [status isEqualToString:stateKeyReturning] ||
              [status isEqualToString:stateKeyBackReturning]) {
        //mau hong : 0xe91e63
        [self.groupStatus setBackgroundColor:UIColorFromRGB(0xe91e63)];
        [self.btnCall setTitle:@"Call Sender"];
        
    }
    else if ([status isEqualToString:stateKeyAssigning] ||
              [status isEqualToString:stateKeyWaiting])
    {
        //mau vang : 13ae8c
        [self.groupStatus setBackgroundColor:UIColorFromRGB(0x13ae8c)];
        [self.btnCall setTitle:@"Call Sender"];
    }
}

- (void)showPopUpRating{
    WKAlertAction *close = [WKAlertAction actionWithTitle:@"Close" style:WKAlertActionStyleCancel handler:^(void){
        NSLog(@"close ");
    }];
    WKAlertAction *rate = [WKAlertAction actionWithTitle:@"Rate" style:WKAlertActionStyleCancel handler:^(void){
        NSLog(@"Rate");
        [self pushControllerWithName:@"RatingOrder" context:nil];
    }];
    
    NSArray *testing = @[close,rate];
    
    [self presentAlertControllerWithTitle:@"Item has been delivered" message:@"Please rate the courier." preferredStyle:WKAlertControllerStyleAlert actions:testing];
}

#pragma mark - DELEGATES

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message
{
    if (message)
    {
        if (![self.tempOState isEqualToString:[message objectForKey:@"orderState"]])
        {
             [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
        }
        self.tempOState = [message objectForKey:@"orderState"];
        NSLog(@"didReceiveMessage : %@",message);
        [self setLayoutWithMessage:message];
    }
}

@end



