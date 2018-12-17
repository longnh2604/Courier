//
//  Constant.h
//  NewProject
//
//  Created by Long Nguyen on 4/11/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#define SVQueue     dispatch_queue_create("com.service", DISPATCH_QUEUE_CONCURRENT)
#define BGQueue     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
#define MainQueue   dispatch_get_main_queue()

#define ImagePlaceHolder    [UIImage imageNamed:@"photodefault"]
#define avatarPlaceHolder   [UIImage imageNamed:@"default_avatar"]

#define RELOAD_MENU_LEFT      [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMenuLeft" object:nil];
#define USER_DID_LOGOUT      [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogout" object:nil];
#define WORKING_MODE           [[NSNotificationCenter defaultCenter] postNotificationName:@"workMode" object:nil];
#define OFFLINE_MODE           [[NSNotificationCenter defaultCenter] postNotificationName:@"offlineMode" object:nil];

#define CHANGE_STATUS_ORDER(status)      [[NSNotificationCenter defaultCenter] postNotificationName:@"changeStatusOrder" object:status];
#define RELOAD_ORDER_AVAILABLE      [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadOrderAvailable" object:nil];

static NSString *UserStoryboard  = @"User";
static NSString *OrderStoryboard  = @"Order";
static NSString *SettingsStoryboard  = @"Settings";
static NSString *OrderBulkStoryboard  = @"OrderBulk";

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

#define minPasswordLength           6

#define minCardNumberLength         12
#define maxCardNumberLength         19

#define phoneLength                 8
#define phoneCodeLength             4
#define reasonLength                140
#define defaultPhonePrefix          @"+65"
#define officePhone                 @"+6568160066"
#define officeMail                  @"courier@zap.delivery"
#define phoneCodeResendInterval     45

#define defaultGoogleMapsZoom       11

#define autoSuggestLatitude         1.368722
#define autoSuggestLongitude        103.807815

#define historyPageSize             20
#define maxLastAddressCount         3

#define currentOrderRefreshInterval 30

#define animationDurationDefault    0.5
#define animationDurationCourier    30.0

//in meters
#define autoSuggestRadius           35000

//In second
#define currency                    @"SGD"

//allow package
#define allowPackage                @[@"DOCUMENT",@"PARCEL"]



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//KEY

#define googleAPIs                  @"AIzaSyCG7vpWJ93uqoEn7XBgvObqwRYT3q5CPcA"////@"AIzaSyAYbqGZ0p0vwFt3kY6Lm12JK4GgM_qjCRA" //???
#define googleAnalytics             @"UA-71852489-1"//sender


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//Color

#define cBgNav                      0xe91e63
#define cTextNav                    0xffffff

#define cBgButton                   0x0098fc
#define cTextButton                 0xffffff


//color guide

//color for button

#define clBlue                      0x29b6f6 //thường dùng cho các button
#define clBlue2                     0x77bce4 //thường dùng cho các row selected , background
#define clBlue3                     0xe1f5fe //thường dùng cho các row selected , background

#define clGray                      0xf7f7f7 // màu nền hoặc màu nền cho button đã disable
#define clGray2                     0xb2b2b2 //màu text
#define clGray3                     0x6b6b6b //màu text
#define clGray4                     0x363434 //màu text

#define clYellow                    0xffeb3b //màu back, menu button
#define clPink                      0xe91e63 //màu navigation bar , màu text



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
/// define state

#define stateKeyAssigning                   @"NEW"
#define stateKeyCancelled                   @"CANCELLED"
#define stateKeyAccepted                    @"ACCEPTED"
#define stateKeyDelivery                    @"DELIVERY"
#define stateKeyCompleted                   @"COMPLETED"
#define stateKeyCourierCancelled            @"COURIER_CANCELLED"
#define stateKeyAdminCancelled              @"DELIVERY_FAILURE"
#define stateKeyReturned                    @"RETURNED"
#define stateKeyReturning                   @"RETURNING"
#define stateKeyInOffice                    @"IN_OFFICE"


#define stateValueAssigning                 @"ASSIGNING"
#define stateValueCancelled                 @"CANCELLED"
#define statevalueAccepted                  @"ASSIGNED"
#define stateValueDelivery                  @"DELIVERING"
#define stateValueCompleted                 @"DELIVERED"
#define stateValueCourierCancelled          @"COURIER CANCELLED"
#define stateValueAdminCancelled            @"DELIVERY FAILURE"
#define stateValueReturned                  @"RETURNED"
#define stateValueReturning                 @"RETURNING"
#define stateValueInOffice                  @"IN OFFICE"

/**
 * Upgrades for return trip function
 */
#define stateKeyWaiting                     @"WAITING"
#define stateKeyBackDelivery               @"BACK_DELIVERY"
#define stateKeyBackReturned               @"BACK_RETURNED"
#define stateKeyBackReturning              @"BACK_RETURNING"
#define stateKeyBackFailure                @"BACK_FAILURE"

#define stateValueWaiting                   @"WAITING"
#define stateValueBackDelivery              @"ORDER COMPLETING \nRETURNING BACK"
#define stateValueBackFailure               @"BACK FAILURE"
#define stateValueBackReturning             @"RETURNING TO RECEIVER"
#define stateValueBackReturned              @"BACK RETURNED"

// Alert tag
#define WAIT_SELECTION_TAG                                  100
#define BACK_CANT_DELIVERY_SELECTION_TAG                    101
#define BACK_CANT_DELIVERY_SELECTION_WITH_RESUME_TAG        102
#define CONFIRM_CANCEL_ORDER_WAITING_SELECTION_TAG          103
#define CANCELLATION_ORDER_TAG                              104
#define RE_ENTER_REASON_CANCELLATION_ORDER_TAG              105

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
/// push notification


static NSString *dvToken     = @"deviceToken";
static NSString *timeResendCode     = @"timeResendCode";


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
/// define type

typedef NS_ENUM(NSUInteger, appState){
    sList = 0,
    sHistory = 1,
    sRewards = 2,
    sCall = 3,
    sAvailable = 4,
    sSetting = 5,
};

#define kTagKLCPopup      10123

