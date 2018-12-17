//
//  HServiceAPI.h
//
//
//  Created by Long Nguyen on 13/04/2015.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.

typedef void(^HandlerBlockArray)(NSArray *results, NSError *error);
typedef void(^HandlerBlockDictionary)(NSDictionary *results, NSError *error);
typedef void(^HandlerBlock)(BOOL finish, NSError *error);

@interface HServiceAPI : NSObject


//USER
+ (void)addAPNSToken:(NSString*)token;

+ (void)loginWithPhone:(NSString*)phone pass:(NSString*)password success:(void(^)())success failed:(void(^)(NSError *error))failed;
+ (void)verifyPhoneNumber:(NSString*)phone success:(void(^)(BOOL success))success;
+ (void)onRequestConfirmCode:(NSString*)phone success:(void(^)(BOOL success))success;
+ (void)confirmCode:(NSString*)code success:(void(^)(BOOL success))success;
+ (void)registerWithFirstName:(NSString*)first last:(NSString*)lastName phone:(NSString*)phone pass:(NSString*)password email:(NSString*)email success:(void(^)())success failed:(void(^)())failed;
+ (void)updateUserInfoWithFirstname:(NSString*)first lastName:(NSString*)last handler:(HandlerBlock)block;
+ (void)changePasswordWithCurrent:(NSString*)current new:(NSString*)newPass handler:(HandlerBlock)block;
+ (void)changeForgotPassword:(NSString*)phone code:(NSString*)smsCode new:(NSString*)newPass handler:(HandlerBlock)block;
+ (void)logout:(HandlerBlock)block;
+ (void)updateAccountwithfirstname:(NSString*)firstname lastname:(NSString*)lastname address:(NSString*)add passport:(NSString*)pass driver:(NSString*)license vehicle:(NSString*)no handler:(void(^)(NSDictionary *result, NSError *error))block;

//MY REWARDS
+ (void)getMyRewardsWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block;

//ORDER
+ (NSURLSessionDataTask*)getOrderAvailableWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block;
+ (void)acceptOrder:(NSString*)oid hander:(HandlerBlockDictionary)block;
+ (void)getCurrentActiveOrder:(HandlerBlockArray)block;
+ (void)onCloseOrder:(HandlerBlock)block;
+ (NSURLSessionDataTask*)getHistoryWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block;
+ (void)getDetailOrderWithID:(NSString*)oid hander:(HandlerBlockDictionary)block;
+ (void)rePublishOrder:(NSString*)oid hander:(HandlerBlockDictionary)block;
+ (void)cancelOrderWithId:(NSString*)oid reason:(NSString*)reason note:(NSString*)note handler:(HandlerBlockDictionary)block;
+ (void)getActiveOrderDetails:(HandlerBlockDictionary)block;
+ (void)confirmPickupCode:(NSString*)code block:(HandlerBlock)block;
+ (void)returnSenderOrOfficeCode:(NSString*)code block:(HandlerBlock)block;
+ (void)confirmDeliveryCode:(NSString*)code block:(HandlerBlock)block;
//+ (void)onReturnSenderorOffice:(NSString*)code success:(void(^)(BOOL success))success;
+ (void)cantDeliveryOrder:(NSString*)oid reason:(NSString*)reason destination:(NSString*)destination handler:(HandlerBlockDictionary)block;
+ (void)onResumeDelivery:(NSString*)oid block:(HandlerBlock)block;
//Bulk jobs
+ (NSURLSessionDataTask*)getBulkOrderAvailableWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block;
+ (void)acceptBulkOrderWithId:(NSString*)bid handler:(HandlerBlockDictionary)block;
+ (void)getCurrentActiveBulkOrder:(HandlerBlockDictionary)block;
+ (void)confirmPickupBulkCode:(NSString*)code block:(HandlerBlock)block;
+ (void)cancelBulkOrderWithId:(NSString*)oid reason:(NSString*)reason note:(NSString*)note handler:(HandlerBlockDictionary)block;
+ (void)cantDeliveryBulkOrder:(NSString*)oid reason:(NSString*)reason destination:(NSString*)destination handler:(HandlerBlockDictionary)block;
+ (void)returnBulkOfficeCode:(NSString*)code withOrderId:(NSString*)oid block:(HandlerBlock)block;
+ (void)backResumeDeliveryBulkOrderCode:(NSString*)oid handler:(HandlerBlock)block;
+ (void)onCloseBulkOrder:(HandlerBlock)block;
+ (void)confirmDeliveryBulkCode:(NSString*)code withOrderId:(NSString*)oid block:(HandlerBlock)block;
+ (NSURLSessionDataTask*)getHistoryBulkOrderWithPage:(NSString*)page handler:(void(^)(NSArray *results,NSString *urlNextPage,NSError *error))block;
/**
 * Upgrades for return trip function
 */

/**
 * Using replace for /order/active/deliver/ API
 */
+ (void)waitingOrderCode:(NSString*)code block:(HandlerBlock)block;

/**
 * Back confirmation pickup code after waiting confirmation code
 */
+ (void)backPickUpOrderCode:(NSString*)code block:(HandlerBlock)block;

+ (void)backDeliverOrderCode:(NSString*)code block:(HandlerBlock)block;

+ (void)backCancelOrderCode:(NSString*)oid reason:(NSString*)reason note:(NSString*)note handler:(HandlerBlockDictionary)block;

+ (void)backCantDeliveryOrderCode:(NSString*)oid reason:(NSString*)reason destination:(NSString*)destination handler:(HandlerBlockDictionary)block;

+ (void)backReturnOrderCode:(NSString*)code block:(HandlerBlock)block;

+ (void)backResumeDeliveryOrderCode:(HandlerBlock)block;

+ (void)postWaiting:(HandlerBlock)block;
+ (void)getWaitingTime:(HandlerBlockDictionary)block;
/**
 * End return trip function
 */


//LOCATION
+ (void)getAutoSuggestAddressWithKey:(NSString*)keySearch handle:(HandlerBlockArray)block;
+ (void)getPlaceInfo:(NSString*)placeId handle:(HandlerBlockDictionary)block;
+ (void)updateCurrentPosition:(NSMutableArray*)currPosition success:(void(^)())success;

//COURIER
+ (void)getNearByCourierWithNorthest:(CLLocationCoordinate2D)north southwest:(CLLocationCoordinate2D)southwest handler:(HandlerBlockArray)block;

//CARD

+ (void)deleteCardWithToken:(NSString*)token handler:(HandlerBlock)block;
+ (void)makePrimaryCardWithToken:(NSString*)token handler:(HandlerBlock)block;
+ (void)updateCardWithToken:(NSString*)token month:(NSString*)month year:(NSString*)year cvv:(NSString*)cvv handler:(void(^)(NSDictionary *result, NSError *error))block;
+ (void)getBrainTreeToken:(HandlerBlock)block;

+ (void)addNewCardWithNumber:(NSString*)number cvv:(NSString*)cvv month:(NSString*)month year:(NSString*)year hander:(void(^)(NSString *token,NSError *error))block;
+ (void)bindCard:(NSString*)token handler:(void(^)(NSDictionary *result, NSError *error))block;

+ (id)convertToJson:(NSDictionary*)userInfo;

@end
