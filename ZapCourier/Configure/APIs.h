//
//  APIs.h
//
//  Created by Long Nguyen on 1/5/15.
//  Copyright (c) 2015 Long Nguyen. All rights reserved.
//

#ifdef STAGGING

//server staging
#define RootURL @"https://app-dev.zap.delivery:443"

#else


//server production
#define RootURL @"https://app.zap.delivery:443"

#endif


////////////////////////////////////////
#define APIVersionPrefix                @"api/v1"

#define API_URL(api)                    [NSString stringWithFormat:@"%@/%@/%@",RootURL,APIVersionPrefix,api]


//USER
#define aLogin                          @"courier/account/login/"
#define aResendCode                     @"courier/account/password_reset/request/"
#define aChangeForgotPass               @"courier/account/password_reset/confirm/"
#define aRequestConfirmCode             @"common/account/phone/request/"
#define aConfirmCode                    @"common/account/phone/confirm/"
#define aRegister                       @"courier/account/signup/"
#define aAccount                        @"courier/account/"
#define aChangePass                     @"common/account/password_change/"
#define aAddAPNS                        @"courier/ios_device/"
#define aLogout                         @"common/account/logout/"

//MYREWARDS
#define aMyRewards                      @"courier/payouts/"

//ORDER
#define aListOrder                      @"courier/order/new/"
#define aMakeOrder                      @"courier/order/"
#define aPickUpOrder                    @"courier/order/active/pickup/"
#define aCantDelivery                   @"courier/order/active/cant_deliver/"
#define aReturnOrderCode                @"courier/order/active/return/"
#define aCompleteDelivery               @"courier/order/active/deliver/"
#define aResumeDelivery                 @"courier/order/active/resume_delivery/"
#define aCloseOrder                     @"courier/order/active/close_processing/"
#define aHistoryOrder                   @"courier/order/closed/"
#define aCurrentOrderActive             @"courier/order/active/"
#define aOrderActiveCancel              @"courier/order/active/cancel/"
#define aQuote                          @"courier/order/quote/"
#define aValidatePromo                  @"courier/order/promo/validate/"
#define aOrderActive                    @"courier/order/active/"
#define aCourierProfile                 @"courier/account/"
//-->bulk version
#define aListBulkOrder                  @"courier/basket/new/"
#define aHistoryBulkOrder               @"courier/basket/closed/"
#define aCurrentBulkOrderActive         @"courier/basket/active/"
#define aPickUpBulkOrder                @"courier/basket/active/pickup/"
#define aBulkOrderActiveCancel          @"courier/basket/active/cancel/"
#define aCantDeliveryBulk               @"courier/basket/active/order/cant_deliver/"
#define aReturnBulkOrderCode            @"courier/basket/active/order/return/"
#define aBulkOrderActiveResumeDelivery  @"courier/basket/active/order/resume_delivery/"
#define aCloseBulkOrder                 @"courier/basket/active/close_processing/"
#define aCompleteDeliveryBulk           @"courier/basket/active/order/deliver/"

//Order return trip
#define aOrderActiveWaiting             @"courier/order/active/waiting/"
#define aOrderActiveBackPickUp          @"courier/order/active/back_pickup/"
#define aOrderActiveBackDeliver         @"courier/order/active/back_deliver/"
#define aOrderActiveBackCancel          @"courier/order/active/back_cancel/"
#define aOrderActiveBackCantDeliver     @"courier/order/active/back_cant_deliver/"
#define aOrderActiveBackReturn          @"courier/order/active/back_return/"
#define aOrderActiveBackResumeDelivery  @"courier/order/active/back_resume_delivery/"

#define aOrderActivePostWaiting         @"courier/order/active/post_waiting/"
#define aOrderActiveGetWaiting          @"courier/order/active/get_waiting/"

//LOCATION
#define aUpdateLocation                 @"courier/position/"
#define aSuggestLocation                @"courier/autocomplete/address/"
#define aPlaceInfo                      @"courier/autocomplete/google_place"

//COURIER

#define aNearCourier                    @"courier/couriers_available/"


//CARD

#define aPayment                        @"courier/payment_method/"
#define aBraintreeToken                 @"courier/payment_method/client_token/"
