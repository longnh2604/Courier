//
//  HServiceAPI.m
//
//
//  Created by Long Nguyen on 13/04/2015.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#import "HServiceAPI.h"
#import "UIView+Toast.h"
#import "VCLogin.h"

@import Braintree;

@interface HServiceAPI ()

@end

@implementation HServiceAPI

#pragma mark - ERROR

+ (id)convertToJson:(NSDictionary*)userInfo{
    NSString *jsonString = [[NSString alloc] initWithData:(NSData *)userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

-(void)getBackLogin:(BaseView*)view
{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:view];
    APPSHARE.jaSide.centerPanel = nav;
    APPSHARE.jaSide.leftPanel = nil;
}
+ (void)checkNewTokenRequired:(id)json{
    if (json!=nil)
    {
        [[Util sharedUtil] hideLoading];
        NSString *codeString = [json stringForKey:@"code"];
        if ([@"account_blocked" isEqualToString:codeString]) {
            [[AuthManager shared] logout];
            //show block window
            [APPSHARE showBlock];
            return;
        }
        
        if ([@"new_token_required" isEqualToString:codeString]) {
            //Logout account
            [[AuthManager shared] logout];
            [APPSHARE showLogin];
            return;
        }
        
    }
}
+ (void)showErrorForJSON:(id)json{
    DLog(@"json = %@",json);
    
    NSString *strError = @"An error has occured. Please check your internet connection or try again later.";
    if (json!=nil)
    {
        [[Util sharedUtil] hideLoading];
        NSString *codeString = [json stringForKey:@"code"];
        if ([@"account_blocked" isEqualToString:codeString]) {
            [[AuthManager shared] logout];
            //show block window
            [APPSHARE showBlock];
            return;
        }
        
        if ([@"new_token_required" isEqualToString:codeString]) {
            // Posting notification to VCOrderAssign controller
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_timer_if_waiting_time_return_trip" object:@"stop_timer_if_waiting_time_return_trip" userInfo:nil];
            //Logout account
            [[AuthManager shared] logout];
            [APPSHARE showLogin];
            return;
        }
        
        NSString *message = [json stringForKey:@"detail"];
        if (message!=nil)
        {
            strError = message;
        }
        else
        {
            //            strError = json.description;
        }
        
        NSString *fieldErrors = [self fieldsErrorDescriptionForJSON:json];
        if (fieldErrors.length>0) {
            strError = [NSString stringWithFormat:@"%@ \n %@",strError,fieldErrors];
        }
    }
    
    [UIAlertView showErrorWithMessage:strError handler:nil];
}

+ (NSString*)fieldsErrorDescriptionForJSON:(NSDictionary*)json{
    if (json!=nil) {
        NSDictionary *dicFields = [json dicForKey:@"fields"];
        if (dicFields.count>0) {
            NSMutableString *strError = [NSMutableString string];
            for (NSString *key in dicFields.allKeys) {
                NSArray *vl = [dicFields arrayForKey:key];
                
                [strError appendFormat:@"%@: ",[[key stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString]];
                for (NSString *error in vl) {
                    [strError appendString:error];
                    [strError appendString:@"\n"];
                }
            }
            return strError;
            
        }
    }
    return nil;
}

#pragma mark - Auth

+ (AFHTTPSessionManager*)manager{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([[AuthManager shared] token]){
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",[AuthManager shared].token] forHTTPHeaderField:@"Authorization"];
    }
//    DLog(@"request header = %@",manager.requestSerializer.HTTPRequestHeaders);
    return manager;
}

+ (void)addAPNSToken:(NSString*)token{
    NSDictionary *params = @{@"apns_token":token,
                             @"device_id":[Util createUUID]};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aAddAPNS) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DLog(@"response = %@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"error = %@",[self convertToJson:error.userInfo]);
    }];
}

#pragma mark - USER

+ (void)loginWithPhone:(NSString*)phone pass:(NSString*)password success:(void(^)())success failed:(void(^)(NSError *error))failed{
    
    
    NSDictionary *params = @{@"phone":phone,
                             @"password":password};
    
    DLog(@"params = %@",params);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:API_URL(aLogin) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DLog(@"response = %@",responseObject);
        
        NSString *token = responseObject[@"token"];
        if (token.length<1) {
            failed(nil);
        }else{
            [[AuthManager shared] login:token];
            //
            NSDictionary *profile = [responseObject dicForKey:@"profile"];
            if (profile!=nil){
                [OUserLogin saveUserWithObject:[responseObject dicForKey:@"profile"]];
            }
            
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        id json = [self convertToJson:error.userInfo];
        
        NSString *code = json[@"code"];
        if ([code isEqualToString:@"invalid_credentials"]) {
            [UIAlertView showErrorWithMessage:@"You've entered wrong credentials" handler:nil];
        }else{
            [self showErrorForJSON:json];
        }
        
        failed(error);
    }];
}

+ (void)verifyPhoneNumber:(NSString*)phone success:(void(^)(BOOL success))success{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"phone":phone};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aResendCode) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        success(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        success(NO);
    }];
}

+ (void)confirmCode:(NSString*)code success:(void(^)(BOOL success))success{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aConfirmCode) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        [OUserLogin confirmedPhone];
        success(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        success(NO);
    }];
}

+ (void)onRequestConfirmCode:(NSString*)phone success:(void(^)(BOOL success))success{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"phone":phone};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aRequestConfirmCode) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        [OUserLogin confirmedPhone];
        success(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        success(NO);
    }];
}

+ (void)registerWithFirstName:(NSString*)first last:(NSString*)lastName phone:(NSString*)phone pass:(NSString*)password email:(NSString*)email success:(void(^)())success failed:(void(^)())failed{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"phone":phone,
                             @"password":password,
                             @"first_name":first,
                             @"last_name":lastName,
                             @"email":email};
    
    DLog(@"params = %@",params);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:API_URL(aRegister) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        
        NSString *token = responseObject[@"token"];
        if (token.length<1) {
            failed(nil);
        }else{
            [[AuthManager shared] login:token];
            //get braintree token
            //register apns
            //start update location
            //
            NSDictionary *profile = [responseObject dicForKey:@"profile"];
            if (profile!=nil){
                [OUserLogin saveUserWithObject:[responseObject dicForKey:@"profile"]];
            }
            
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        id json = [self convertToJson:error.userInfo];
        
        NSString *code = json[@"code"];
        if ([code isEqualToString:@"validation_error"]) {
            [UIAlertView showErrorWithMessage:@"This phone number is already in use" handler:nil];
        }else{
            [self showErrorForJSON:json];
        }
        
        failed(error);
    }];
}

+ (void)updateUserInfoWithFirstname:(NSString*)first lastName:(NSString*)last handler:(HandlerBlock)block{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"first_name":first,
                             @"last_name":last};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager PUT:API_URL(aAccount) parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(NO,error);
    }];
}

+ (void)changePasswordWithCurrent:(NSString*)current new:(NSString*)newPass handler:(HandlerBlock)block{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"old_password":current,
                             @"new_password":newPass};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aChangePass) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(NO,error);
    }];
}

+ (void)changeForgotPassword:(NSString*)phone code:(NSString *)smsCode new:(NSString *)newPass handler:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"phone":phone,
                             @"code":smsCode,
                             @"password":newPass};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aChangeForgotPass) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(NO,error);
    }];
}

+ (void)logout:(HandlerBlock)block{
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *param = @{@"ios_device_id":[Util createUUID]};
    [manager POST:API_URL(aLogout) parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        block(NO,error);
    }];
}

#pragma mark - ORDER

+ (void)getDetailOrderWithID:(NSString*)oid hander:(HandlerBlockDictionary)block
{
    [[Util sharedUtil] showLoading];
    NSString *strApi = [NSString stringWithFormat:@"%@%@/",API_URL(aMakeOrder),oid];
    AFHTTPSessionManager *manager = [self manager];
    
    [manager GET:strApi parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        [[Util sharedUtil] hideLoading];
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        [[Util sharedUtil] hideLoading];
        DLog(@"error = %@",[self convertToJson:error.userInfo]);
        [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
        block(nil,error);
    }];
}

+ (void)getActiveOrderDetails:(HandlerBlockDictionary)block
{
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:API_URL(aOrderActive) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"error = %@",[self convertToJson:error.userInfo]);
        [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
        block(nil,error);
    }];
}

+ (void)rePublishOrder:(NSString*)oid hander:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@%@/repost/",API_URL(aMakeOrder),oid];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:strApi parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(nil,error);
    }];
}

+ (void)cancelOrderWithId:(NSString*)oid reason:(NSString*)reason note:(NSString*)note handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@",API_URL(aOrderActiveCancel)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (reason) [params setObject:reason forKey:@"reason"];
    if (note) [params setObject:note forKey:@"note"];
    
    AFHTTPSessionManager *manger = [self manager];
    [manger POST:strApi
      parameters:(reason==nil && note==nil)?nil:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         block(responseObject,nil);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[Util sharedUtil] hideLoading];
         [self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)cancelBulkOrderWithId:(NSString*)oid reason:(NSString*)reason note:(NSString*)note handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@",API_URL(aBulkOrderActiveCancel)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (reason) [params setObject:reason forKey:@"reason"];
    if (note) [params setObject:note forKey:@"note"];
    
    AFHTTPSessionManager *manger = [self manager];
    [manger POST:strApi
      parameters:(reason==nil && note==nil)?nil:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         block(responseObject,nil);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[Util sharedUtil] hideLoading];
         [self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)cantDeliveryOrder:(NSString*)oid reason:(NSString*)reason destination:(NSString*)destination handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@",API_URL(aCantDelivery)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (reason) [params setObject:reason forKey:@"return_reason"];
    if (destination) [params setObject:destination forKey:@"return_destination"];
    
    AFHTTPSessionManager *manger = [self manager];
    [manger POST:strApi
      parameters:(reason==nil && destination==nil)?nil:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         block(responseObject,nil);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[Util sharedUtil] hideLoading];
         [self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)cantDeliveryBulkOrder:(NSString*)oid reason:(NSString*)reason destination:(NSString*)destination handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@",API_URL(aCantDeliveryBulk)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (oid) [params setObject:oid forKey:@"order_id"];
    if (reason) [params setObject:reason forKey:@"return_reason"];
    if (destination) [params setObject:destination forKey:@"return_destination"];
    
    AFHTTPSessionManager *manger = [self manager];
    [manger POST:strApi
      parameters:(reason==nil && destination==nil && oid==nil)?nil:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         block(responseObject,nil);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[Util sharedUtil] hideLoading];
         [self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (NSURLSessionDataTask*)getOrderAvailableWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block{
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"page":page,
                             @"page_size":[NSString stringWithFormat:@"%d",historyPageSize]};
    
    DLog(@"params = %@",params);
    return [manager GET:API_URL(aListOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                [[Util sharedUtil] hideLoading];
                DLog(@"response = %@",responseObject);
                NSArray *rs = responseObject[@"results"];
                 NSString *strNext = [(NSDictionary*)responseObject stringForKey:@"next"];
                 NSMutableArray *ar = [NSMutableArray array];
                 if (rs.count>0)
                 {
                     for (NSDictionary *dic in rs)
                     {
                         OOrderAvailable *o = [OOrderAvailable convertToObject:dic];
                         
                         [ar addObject:o];
                     }
                     block(ar,strNext,nil);
                 }else{
                     block(nil,nil,nil);
                 }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(nil,nil,error);
     }];
}


+ (NSURLSessionDataTask*)getHistoryWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block{
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"page":page,
                             @"page_size":[NSString stringWithFormat:@"%d",historyPageSize]};
    DLog(@"params = %@",params);
    return [manager GET:API_URL(aHistoryOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        NSArray *rs = responseObject[@"results"];
        NSString *urlNextPage = [(NSDictionary*)responseObject stringForKey:@"next"];
        NSMutableArray *ar = [NSMutableArray array];
        if (rs.count>0) {
            for (NSDictionary *dic in rs) {
                OOrderAvailable *o = [OOrderAvailable convertToObject:dic];
                
                [ar addObject:o];
            }
            block(ar,urlNextPage,nil);
        }else{
            block(nil,urlNextPage,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
        block(nil,nil,error);
    }];
}

#pragma mark - BULK ORDER

+ (NSURLSessionDataTask*)getHistoryBulkOrderWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block{
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"page":page};
    DLog(@"params = %@",params);
    return [manager GET:API_URL(aHistoryBulkOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        NSArray *rs = responseObject[@"results"];
        NSString *urlNext = [(NSDictionary*)responseObject stringForKey:@"next"];
        NSMutableArray *ar = [NSMutableArray array];
        if (rs.count>0)
        {
            for (NSDictionary *dic in rs)
            {
                OBulk *o = [OBulk convertToObject:dic];
                
                [ar addObject:o];
            }
            block(ar,urlNext,nil);
        }else{
            block(nil,nil,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
        block(nil,nil,error);
    }];
}


+ (void)acceptBulkOrderWithId:(NSString*)bid handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/accept/",API_URL(aListBulkOrder),bid];
//    DLog(@"strUrl = %@",strUrl);
    
    [manager POST:strUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
//        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(nil,error);
    }];
}

+ (NSURLSessionDataTask*)getBulkOrderAvailableWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block{
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"page":page,
                             @"page_size":[NSString stringWithFormat:@"%d",historyPageSize]};
    return [manager GET:API_URL(aListBulkOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                [[Util sharedUtil] hideLoading];
                NSArray *rs = responseObject[@"results"];
                NSString *urlNext = [(NSDictionary*)responseObject stringForKey:@"next"];
                NSMutableArray *ar = [NSMutableArray array];
                if (rs.count>0)
                {
                    for (NSDictionary *dic in rs)
                    {
                        OBulk *o = [OBulk convertToObject:dic];
                        
                        [ar addObject:o];
                    }
                    block(ar,urlNext,nil);
                }else{
                    block(nil,nil,nil);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [[Util sharedUtil] hideLoading];
                [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
                block(nil,nil,error);
            }];
}

#pragma mark - LOCATIONS

+ (void)getAutoSuggestAddressWithKey:(NSString*)keySearch handle:(HandlerBlockArray)block{
    
    BOOL useProxy = YES;
    if (useProxy) {
        CGFloat lat = autoSuggestLatitude;
        CGFloat lon = autoSuggestLongitude;
        CLLocation *loc = [LocationManager shared].lastLocation;
        if (loc) {
            lat = [LocationManager shared].lastLocation.coordinate.latitude;
            lon = [LocationManager shared].lastLocation.coordinate.longitude;
        }
        
        AFHTTPSessionManager *manager = [self manager];
        NSDictionary *params = @{@"input":keySearch,
                                 @"location":[NSString stringWithFormat:@"%f,%f",autoSuggestLatitude,autoSuggestLongitude]};
        
        [manager GET:API_URL(aSuggestLocation) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [[Util sharedUtil] hideLoading];
            
            DLog(@"resonse = %@",responseObject);
            block(responseObject,nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[Util sharedUtil] hideLoading];
            DLog(@"error = %@",error.localizedDescription);
            block(nil,error);
        }];
    }else{
        NSDictionary *params = @{@"input":keySearch,
                                 @"location":[NSString stringWithFormat:@"%f,%f",autoSuggestLatitude,autoSuggestLongitude],
                                 @"key":googleAPIs,
                                 @"radius":@autoSuggestRadius};
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:@"https://maps.googleapis.com/maps/api/place/autocomplete/json" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [[Util sharedUtil] hideLoading];
            NSArray *ar = responseObject[@"predictions"];
            block(ar,nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [[Util sharedUtil] hideLoading];
            DLog(@"error = %@",error.localizedDescription);
            block(nil,error);
        }];
    }
}

+ (void)getPlaceInfo:(NSString*)placeId handle:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@/%@",API_URL(aPlaceInfo),placeId];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:strApi parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        DLog(@"response = %@",responseObject);
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        DLog(@"error = %@",error.localizedDescription);
        block(nil,error);
    }];
}


#pragma mark - COURIER

+ (void)getNearByCourierWithNorthest:(CLLocationCoordinate2D)north southwest:(CLLocationCoordinate2D)southwest handler:(HandlerBlockArray)block{
    NSDictionary *params = @{@"northeast":[NSString stringWithFormat:@"%f,%f",north.latitude,north.longitude],
                             @"southwest":[NSString stringWithFormat:@"%f,%f",southwest.latitude,southwest.longitude]};
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:API_URL(aNearCourier) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DLog(@"response = %@",responseObject);
        NSMutableArray *arCourier = [NSMutableArray array];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in responseObject) {
                OCourierTrack *c = [OCourierTrack trackMap:dic];
                
                [arCourier addObject:c];
            }
            
            block(arCourier,nil);
        }else{
            block(nil,nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"error = %@",error.localizedDescription);
        block(nil,error);
    }];
}


#pragma mark - CARD

+ (void)deleteCardWithToken:(NSString*)token handler:(HandlerBlock)block{
    
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSString *strApi = [NSString stringWithFormat:@"%@%@/",API_URL(aPayment),token];
    DLog(@"strApi = %@",strApi);
    [manager DELETE:strApi parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(NO,error);
    }];
    
}

+ (void)makePrimaryCardWithToken:(NSString*)token handler:(HandlerBlock)block{
    
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"make_default":@"true"};
    
    NSString *strApi = [NSString stringWithFormat:@"%@%@/",API_URL(aPayment),token];
    DLog(@"strApi = %@",strApi);
    [manager PUT:strApi parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(NO,error);
    }];
    
}

+ (void)updateCardWithToken:(NSString*)token month:(NSString*)month year:(NSString*)year cvv:(NSString*)cvv handler:(void(^)(NSDictionary *result, NSError *error))block{
    
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"expiration_month":month,
                             @"expiration_year":year,
                             @"cvv":cvv};
    
    NSString *strApi = [NSString stringWithFormat:@"%@%@/",API_URL(aPayment),token];
    
    [manager PUT:strApi parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(nil,error);
    }];
    
}

+ (void)getBrainTreeToken:(HandlerBlock)block{
    
    AFHTTPSessionManager *manager = [self manager];
    
    [manager GET:API_URL(aBraintreeToken) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[AuthManager shared] saveBrainTreeToken:responseObject[@"client_token"]];
        block(YES,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO,error);
    }];
}

+ (void)addNewCardWithNumber:(NSString*)number cvv:(NSString*)cvv month:(NSString*)month year:(NSString*)year hander:(void(^)(NSString *token,NSError *error))block{
    [[Util sharedUtil] showLoading];
    
    NSString *token = [[AuthManager shared] getBrainTreeToken];
    if (token==nil) {
        [HServiceAPI getBrainTreeToken:^(BOOL finish, NSError *error) {
            //
            [self addNewCardWithNumber:number cvv:cvv month:month year:year hander:^(NSString *token, NSError *error) {
                block(token,error);
            }];
        }];
        return;
    }
    
    
    BTCard *card = [[BTCard alloc] initWithNumber:number expirationMonth:month expirationYear:year cvv:cvv];
    
    BTAPIClient *api = [[BTAPIClient alloc]initWithAuthorization:token];
    
    BTCardClient *client = [[BTCardClient alloc]initWithAPIClient:api];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        if (!error){
            block(tokenizedCard.nonce,nil);
        }else{
            block(nil,error);
        }
    }];
}

+ (void)bindCard:(NSString*)token handler:(void(^)(NSDictionary *result, NSError *error))block{
    
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"payment_method_nonce":token};
    DLog(@"params = %@",params);
    DLog(@"api = %@",API_URL(aPayment));
    [manager POST:API_URL(aPayment) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[Util sharedUtil] hideLoading];
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[Util sharedUtil] hideLoading];
        [self showErrorForJSON:[self convertToJson:error.userInfo]];
        block(nil,error);
    }];
    
}

+ (void)getMyRewardsWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block{
    AFHTTPSessionManager *manager = [self manager];
    
    NSDictionary *params = @{@"page":page,
                             @"page_size":[NSString stringWithFormat:@"%d",historyPageSize],
                             @"status":@"closed"};
    DLog(@"params = %@",params);
    [manager GET:API_URL(aMyRewards) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         NSArray *rs = responseObject[@"results"];
         NSString *strUrl = [(NSDictionary*)responseObject stringForKey:@"next"];
         NSMutableArray *ar = [NSMutableArray array];
         if (rs.count>0)
         {
             for (NSDictionary *dic in rs)
             {
                 ORewards *o = [ORewards convertToObject:dic];
                 
                 [ar addObject:o];
             }
             
             block(ar,strUrl,nil);
         }else{
             block(nil,nil,nil);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
//         [self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,nil,error);
     }];
}

+ (void)updateCurrentPosition:(NSMutableArray*)currPosition success:(void(^)())success
{
    AFHTTPSessionManager *manager = [self manager];
    
    if (currPosition == nil) return;

    NSDictionary *params = @{@"position":[currPosition objectAtIndex:0],
                             @"course":@"",
                             @"altitude":@"",
                             @"accuracy":@"",
                             @"speed":@""};
    
    [manager POST:API_URL(aUpdateLocation) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success();
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         id json = [self convertToJson:error.userInfo];
         if (json!=nil)
         {
             NSString *codeString = [json stringForKey:@"code"];
             if ([@"account_blocked" isEqualToString:codeString]) {
                 [[AuthManager shared] logout];
                 //show block window
                 [APPSHARE showBlock];
             }
             
             if ([@"new_token_required" isEqualToString:codeString]) {
                 //Logout account
                 [[AuthManager shared] logout];
                 [APPSHARE showLogin];
             }
             
         }
     }];
}

+ (void)acceptOrder:(NSString *)oid hander:(HandlerBlockDictionary)block
{
    NSString *strApi = [NSString stringWithFormat:@"%@%@/accept/",API_URL(aListOrder),oid];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:strApi parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         block(responseObject,nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         block(nil,error);
     }];
}

+ (void)getCurrentActiveOrder:(HandlerBlockArray)block
{
    [[Util sharedUtil] showLoading];
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:API_URL(aCurrentOrderActive) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         DLog(@"response = %@",responseObject);
         NSDictionary *rs = responseObject;
         NSMutableArray *ar = [[NSMutableArray alloc]init];
         if (rs.count > 0)
         {
             [[Util sharedUtil] hideLoading];
             OOrderAvailable *o = [OOrderAvailable convertToObject:rs];
             [ar addObject:o];
             block(ar,nil);
         }
         else
         {
             [[Util sharedUtil] hideLoading];
             block(nil,nil);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
//         [self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)getCurrentActiveBulkOrder:(HandlerBlockDictionary)block
{
    [[Util sharedUtil] showLoading];
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:API_URL(aCurrentBulkOrderActive) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(responseObject,nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)confirmPickupCode:(NSString*)code block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aPickUpOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(NO, error);
     }];
}

+ (void)confirmPickupBulkCode:(NSString*)code block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aPickUpBulkOrder) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(NO, error);
     }];
}

+ (void)returnSenderOrOfficeCode:(NSString*)code block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aReturnOrderCode) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES,nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(NO,error);
     }];
}

+ (void)returnBulkOfficeCode:(NSString*)code withOrderId:(NSString*)oid block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    NSDictionary *params = @{@"code":code,@"order_id":oid};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aReturnBulkOrderCode) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES,nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(NO,error);
     }];
}

+ (void)onCloseOrder:(HandlerBlock)block
{
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aCloseOrder) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         block(YES,nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         block(NO,error);
     }];
}

+ (void)onCloseBulkOrder:(HandlerBlock)block
{
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aCloseBulkOrder) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         block(YES,nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         block(NO,error);
     }];
}

+ (void)confirmDeliveryCode:(NSString*)code block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aCompleteDelivery) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         [[Util sharedUtil] hideLoading];
         block(NO, error);
     }];
}

+ (void)confirmDeliveryBulkCode:(NSString*)code withOrderId:(NSString*)oid block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code,@"order_id":oid};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aCompleteDeliveryBulk) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         [[Util sharedUtil] hideLoading];
         block(NO, error);
     }];
}

+ (void)onResumeDelivery:(NSString*)oid block:(HandlerBlock)block
{
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aResumeDelivery) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

/**
 * Upgrades for return trip function
 */

/**
 * Using replace for /order/active/deliver/ API
 */
+ (void)waitingOrderCode:(NSString*)code block:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aOrderActiveWaiting) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"WaitingOrderCode API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

/**
 * Back confirmation pickup code after waiting confirmation code
 */
+ (void)backPickUpOrderCode:(NSString*)code block:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aOrderActiveBackPickUp) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"BackPickUpOrderCode API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

+ (void)backDeliverOrderCode:(NSString*)code block:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aOrderActiveBackDeliver) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"BackPickUpOrderCode API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

+ (void)backCancelOrderCode:(NSString*)oid reason:(NSString*)reason note:(NSString*)note handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@",API_URL(aOrderActiveBackCancel)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (reason) [params setObject:reason forKey:@"reason"];
    if (note) [params setObject:note forKey:@"note"];
    
    AFHTTPSessionManager *manger = [self manager];
    [manger POST:strApi
      parameters:(reason==nil && note==nil)?nil:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         DLog(@"BackCancelOrderCode API --> response = %@",responseObject);
         [[Util sharedUtil] hideLoading];
         block(responseObject,nil);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)backCantDeliveryOrderCode:(NSString*)oid reason:(NSString*)reason destination:(NSString*)destination handler:(HandlerBlockDictionary)block{
    [[Util sharedUtil] showLoading];
    
    NSString *strApi = [NSString stringWithFormat:@"%@",API_URL(aOrderActiveBackCantDeliver)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (reason) [params setObject:reason forKey:@"return_reason"];
    if (destination) [params setObject:destination forKey:@"return_destination"];
    
    AFHTTPSessionManager *manger = [self manager];
    [manger POST:strApi
      parameters:(reason==nil && destination==nil)?nil:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         DLog(@"BackCantDeliveryOrderCode API --> response = %@",responseObject);
         [[Util sharedUtil] hideLoading];
         block(responseObject,nil);
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(nil,error);
     }];
}

+ (void)backReturnOrderCode:(NSString*)code block:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"code":code};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aOrderActiveBackReturn) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"BackReturnOrderCode API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         //[self showErrorForJSON:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

+ (void)backResumeDeliveryOrderCode:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aOrderActiveBackResumeDelivery) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"BackResumeDeliveryOrderCode API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

+ (void)backResumeDeliveryBulkOrderCode:(NSString*)oid handler:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    NSDictionary *params = @{@"order_id":oid};
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aBulkOrderActiveResumeDelivery) parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"BackResumeDeliveryOrderCode API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(YES, error);
     }];
}

+ (void)postWaiting:(HandlerBlock)block {
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager POST:API_URL(aOrderActivePostWaiting) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"PostWaiting API --> response = %@",responseObject);
         block(YES, nil);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[Util sharedUtil] hideLoading];
         [self checkNewTokenRequired:[self convertToJson:error.userInfo]];
         block(NO, error);
     }];
}

+ (void)getWaitingTime:(HandlerBlockDictionary)block
{
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:API_URL(aOrderActiveGetWaiting) parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[Util sharedUtil] hideLoading];
         DLog(@"------>getWaitingTime.response = %@",responseObject);
         NSDictionary *waitingTimeDict = responseObject;
         if (waitingTimeDict.count > 0)
         {
             block(waitingTimeDict, nil);
         }
         else
         {
             block(nil,nil);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         block(nil,error);
     }];
}

+ (void)updateAccountwithfirstname:(NSString*)firstname lastname:(NSString*)lastname address:(NSString*)add passport:(NSString*)pass driver:(NSString*)license vehicle:(NSString*)no handler:(void(^)(NSDictionary *result, NSError *error))block{
    
    [[Util sharedUtil] showLoading];
    
    AFHTTPSessionManager *manager = [self manager];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if(firstname)[params setObject:firstname forKey:@"first_name"];
    if(lastname)[params setObject:lastname forKey:@"last_name"];
    if(add)[params setObject:add forKey:@"address"];
    if(pass)[params setObject:pass forKey:@"passport"];
    if(license)[params setObject:license forKey:@"drivers_license"];
    if(no)[params setObject:no forKey:@"vehicle_plate"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"PUT" URLString:API_URL(aAccount) parameters:nil error:nil];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setValue:[NSString stringWithFormat:@"JWT %@",[AuthManager shared].token] forHTTPHeaderField:@"Authorization"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            [[Util sharedUtil] hideLoading];
            block(responseObject,nil);
        } else {
            [[Util sharedUtil] hideLoading];
            [self showErrorForJSON:[self convertToJson:error.userInfo]];
            block(nil,error);
        }
    }] resume];
}

@end
