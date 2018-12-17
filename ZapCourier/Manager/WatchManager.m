//
//  WatchManager.m
//  ZapCourier
//
//  Created by Long Nguyen on 4/4/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import "WatchManager.h"

@implementation WatchManager

+ (WatchManager *)shared {
    static WatchManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[WatchManager alloc] init];
    });
    
    return _shared;
}

- (void)enableWatchWithDelegate:(id)delegate{
    if(WCSession.isSupported){
        WCSession* session = WCSession.defaultSession;
        session.delegate = delegate;
        [session activateSession];
    }
}

-(void)sendDataToWatch:(NSArray*)orders withUserStatus:(NSString *)status
{
    NSMutableArray *tableData = [NSMutableArray array];
    for (NSInteger i = 0; i < [orders count]; i++)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];

        OOrderAvailable *order = orders[i];
        NSString *returnCheck = [NSString stringWithFormat:@"%d",order.isReturnTrip];

        [dic setObject:order.oid forKey:@"orderId"];
        [dic setObject:order.price forKey:@"orderPrice"];
        [dic setObject:order.pickupAddress forKey:@"orderPickup"];
        [dic setObject:order.dropoffAddress forKey:@"orderDropoff"];
        [dic setObject:returnCheck forKey:@"orderReturn"];

        [tableData addObject:dic];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tableData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendDataToWatchWithJson:jsonString];
}

- (void)sendDataToWatchWithJson:(NSString*)jsonString{
    NSDictionary* message = @{@"action":@"login",
                              @"user":[NSString stringWithFormat:@"%@",APPSHARE.userLogin.firstName],
                              @"data":(jsonString!=nil)?jsonString:@"",
                              @"status":@"1"
                              };
    
    [self sendMessage:message];
}

- (void)completeOrder
{
    NSDictionary* message = @{@"action":@"completed"
                              };
    [self sendMessage:message];
}

- (void)alertNewOrder
{
    NSDictionary* message = @{@"action":@"haptic"
                              };
    [self sendMessage:message];
}

-(void)sendStatusOrder:(OOrderAvailable *)order
{
    if(WCSession.isSupported)
    {
        if(WCSession.defaultSession.reachable)
        {
            [Util downloadImage:[NSURL URLWithString:order.senderPhoto] done:^(NSString *strImg)
             {
                 NSDictionary* message = @{@"action":@"assigned",
                                           @"orderId":order.oid,
                                           @"senderName":order.senderName,
                                           @"senderPhone":order.phonePickup,
                                           @"orderState":order.state,
                                           @"destination":order.returnDropoff,
                                           @"senderAvatar":strImg
                                           };
                 
                 [WCSession.defaultSession sendMessage:message replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage){
                     DLog(@"response = %@",replyMessage);
                 }errorHandler:^(NSError * _Nonnull error){
                     DLog(@"error = %@",error.localizedDescription);
                 }];
             }];
        }
        else
        {
            
        }
    }
    else
    {
        
    }
}

- (void)sendMessage:(NSDictionary*)meg{
    if(WCSession.isSupported)
    {
        if (WCSession.defaultSession.isReachable) {
            [WCSession.defaultSession sendMessage:meg replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage){
                DLog(@"response = %@",replyMessage);
            }errorHandler:^(NSError * _Nonnull error){
                DLog(@"error = %@",error.localizedDescription);
            }];
        }
    }
}


- (void)getOrderAvailable{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([[AuthManager shared] token]){
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",[AuthManager shared].token] forHTTPHeaderField:@"Authorization"];
    }else{
        
    }
    
    NSDictionary *params = @{@"page":@"1",
                             @"page_size":@"5"};
    
    DLog(@"params = %@",params);
    [manager GET:API_URL(aListOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                DLog(@"response = %@",responseObject);
                NSArray *rs = responseObject[@"results"];
                NSMutableArray *ar = [NSMutableArray array];
                if (rs.count>0)
                {
                    for (NSDictionary *item in rs)
                    {
                            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                            
                            [dic setObject:[item stringForKey:@"id"] forKey:@"orderId"];
                            [dic setObject:[item stringForKey:@"courier_reward"] forKey:@"orderPrice"];
                            [dic setObject:[item stringForKey:@"pickup_address"] forKey:@"orderPickup"];
                            [dic setObject:[item stringForKey:@"destination_address"] forKey:@"orderDropoff"];
                            [dic setObject:[item stringForKey:@"is_return_trip"] forKey:@"orderReturn"];
                            
                            [ar addObject:dic];
                    }
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ar options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        [self sendDataToWatchWithJson:jsonString];
                    
                }else{
                    [self sendDataToWatchWithJson:nil];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self sendDataToWatchWithJson:nil];
            }];
}

@end
