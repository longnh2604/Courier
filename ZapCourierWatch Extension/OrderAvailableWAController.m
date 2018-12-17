//
//  OrderAvailableWAController.m
//  ZapCourier
//
//  Created by Long Nguyen on 2/1/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "OrderAvailableWAController.h"
#import "OrderWApp.h"
#import "WATableRow.h"
#import "OrderDetailWAController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface OrderAvailableWAController ()<WCSessionDelegate>
{
    NSArray *_eventsData;
    NSString *dataTable;
    NSString *userStatus;
}
@end

@implementation OrderAvailableWAController
@synthesize WATableview;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    dataTable = [context objectForKey:@"data"];
    userStatus = [context objectForKey:@"status"];
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
    [self setupTable];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)setupTable
{
    [self setTitle:[NSString stringWithFormat:@"Available"]];
    [self.lblTableNote setText:@"No available \n orders"];
    
    if (dataTable.length > 6)
    {
        if ([userStatus isEqualToString:@"1"])
        {
            [self showOnline];
        }
        if ([userStatus isEqualToString:@"0"])
        {
            [self showOffline];
        }
        
        NSError *e;
        NSArray *dic= [NSJSONSerialization JSONObjectWithData:[dataTable dataUsingEncoding:NSUTF8StringEncoding] options:  NSJSONReadingMutableContainers error: &e];
        
        _eventsData = [OrderWApp eventsList:dic];
        
        NSMutableArray *rowTypesList = [NSMutableArray array];
        
        for (OrderWApp *event in _eventsData)
        {
            if (event.orderId.length > 0)
            {
                [rowTypesList addObject:@"WATableRow"];
            }
            else
            {
                [rowTypesList addObject:@"WATableRow"];
            }
        }
        
        [WATableview setRowTypes:rowTypesList];
        
        for (NSInteger i = 0; i < WATableview.numberOfRows; i++)
        {
            NSObject *row = [WATableview rowControllerAtIndex:i];
            OrderWApp *event = _eventsData[i];
            
            if ([row isKindOfClass:[WATableRow class]])
            {
                WATableRow *tbr = (WATableRow *) row;
                [tbr.rowTitle setText:[NSString stringWithFormat:@"Order #%@",event.orderId]];
                [tbr.rowCost setText:[NSString stringWithFormat:@"$%@",event.orderPrice]];
                [tbr.rowPickUp setText:event.orderPickup];
                [tbr.rowDropOff setText:event.orderDropoff];
            }
        }
    }
    else
    {
        if ([userStatus isEqualToString:@"1"])
        {
            [self showOnline];
        }
        if ([userStatus isEqualToString:@"0"])
        {
            [self showOffline];
        }
    }
}

- (void)showOnline
{
    if (dataTable.length > 6 )
    {
        [self.lblTableNote setHidden:YES];
        [self.WATableview setHidden:NO];
    }
    else
    {
        [self.lblTableNote setHidden:NO];
        [self.WATableview setHidden:YES];
    }
    
    [self.lblTableNote setText:@"No available \n orders"];
}

- (void)showOffline
{
    [self.lblTableNote setHidden:NO];
    [self.WATableview setHidden:YES];
    [self.lblTableNote setText:@"You are currently \n offline"];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    NSLog(@"message = %@",message);
    if(message)
    {
        NSString *action = [message objectForKey:@"action"];
        if ([action isEqualToString:@"login"])
        {
            dataTable = [message objectForKey:@"data"];
            userStatus = [message objectForKey:@"status"];
            [self setupTable];
        }else if ([action isEqualToString:@"assigned"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"OrderAssignWAController"] contexts:@[message]];
        }else if (([action isEqualToString:@"haptic"]))
        {
            [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
        }else if ([action isEqualToString:@"nonLogin"])
        {
            [WKInterfaceController reloadRootControllersWithNames:@[@"SplashWAController"] contexts:@[message]];
        }
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    OrderWApp *o = _eventsData[rowIndex];
    
    NSDictionary* message = @{@"oid":o.orderId,
                              @"price":o.orderPrice,
                              @"pickup":o.orderPickup,
                              @"dropoff":o.orderDropoff,
                              @"return":o.orderReturn
                              };
    
    [self pushControllerWithName:@"OrderDetailWAController" context:message];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification
{
    NSLog(@"Check");
}

- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification
{
    NSLog(@"Check");
}

@end



