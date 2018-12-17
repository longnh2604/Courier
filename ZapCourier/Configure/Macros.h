//
//  Macros.h
//  NewProject
//
//  Created by Long Nguyen on 4/11/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#define NEW_VC(className)           [[className alloc] initWithNibName:[Util getXIB:[className class]] bundle:nil]
#define NewVC(storyboard,className) [Util initViewController:[className class] storyboard:storyboard]

#define VCUSER(className)        [Util initViewController:[className class] storyboard:@"User"]
#define VCORDER(className)        [Util initViewController:[className class] storyboard:@"Order"]
#define VCORDERBULK(className)        [Util initViewController:[className class] storyboard:@"OrderBulk"]
#define VCAVAILABEL(className)        [Util initViewController:[className class] storyboard:@"Available"]
#define VCSETTING(className)        [Util initViewController:[className class] storyboard:@"Settings"]

#define colorFromRGB(r, g, b)       ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1])
#define UIColorFromRGB(rgbValue)    [UIColor \
                                    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                    green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                    blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define IS_IPAD                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5                 (([[UIScreen mainScreen] bounds].size.height) == 568)
#define IS_IPHONE_4                 (([[UIScreen mainScreen] bounds].size.height) == 480)
#define IS_SIMULATOR                (TARGET_IPHONE_SIMULATOR)

#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define UserDefaults                [NSUserDefaults standardUserDefaults]

#define SYSTEM_NAME                 ([[UIDevice currentDevice ] systemName])
#define SYSTEM_VERSION              ([[[UIDevice currentDevice ] systemVersion] floatValue])

#define APP_VERSION                 [[[NSBundle mainBundle] infoDictionary]     objectForKey:@"CFBundleShortVersionString"]
#define APP_BUILD                   [[[NSBundle mainBundle] infoDictionary]     objectForKey:@"CFBundleVersion"]

#define DEVICE_MODEL                ([[UIDevice currentDevice ] model])
#define DEVICE_MODEL_LOCALIZED      ([[UIDevice currentDevice ] localizedModel])
#define DEVICE_NAME                 ([[UIDevice currentDevice ] name])
#define DEVICE_ORIENTATION          ([[UIDevice currentDevice ] orientation])
#define DEVICE_TYPE                 ([[UIDevice currentDevice ] deviceType])
#define UDID                        [[UIDevice currentDevice] identifierForVendor].UUIDString


#define SCREEN_HEIGHT_PORTRAIT      ( [[UIScreen mainScreen ] bounds ].size.height )
#define SCREEN_WIDTH_PORTRAIT       ( [[UIScreen mainScreen ] bounds ].size.width )
#define SCREEN_HEIGHT_LANDSCAPE     ( [[UIScreen mainScreen ] bounds ].size.width )
#define SCREEN_WIDTH_LANDSCAPE      ( [[UIScreen mainScreen ] bounds ].size.height )

#define xFrame(a)                   a.frame.origin.x
#define yFrame(b)                   b.frame.origin.y
#define wFrame(w)                   w.frame.size.width
#define hFrame(w)                   w.frame.size.height

#define safeString(str)             [Util getSafeString:str]


#define RESIGN_KEYBOARD             [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
#define APPSHARE                    ((AppDelegate *)[[UIApplication sharedApplication] delegate])
