//
//  Utils.h
//  NewProject
//
//  Created by Long Nguyen on 4/11/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

typedef void(^VoidBlock)(void);
typedef void(^ErrorBlock)(NSError *error);
typedef void(^ResultArrayBlock)(NSArray *arrResult);

@interface Util : NSObject {
}

// get file xib
+ (NSString *)getXIB:(Class)fromClass;
+ (void)fixDownyView:(id)viewController;

+ (Util *) sharedUtil;
+ (AppDelegate *)appDelegate;

+ (id)initWithXib:(NSString*)name;
+ (id)initViewController:(Class)classView storyboard:(NSString*)strStoryboard;

//loading view
- (void)showLoading;
- (void)showLoadingView:(UIView*)view;
- (void)hideLoading;

+(void)clearCacheImage;

+ (void)printAllSystemFonts;
//
+(NSString*)formatCurrencyWithNumber:(NSString*)number withSymbol:(NSString*)symbol;
+(BOOL) NSStringIsValidEmail:(NSString *)checkString;
//
+ (void)setValue:(id)value forKey:(NSString *)key;
+ (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
+ (void)setObject:(id)obj forKey:(NSString *)key;
+ (id)valueForKey:(NSString *)key;
+ (id)valueForKeyPath:(NSString *)keyPath;
+ (id)objectForKey:(NSString *)key;
+ (void)removeObjectForKey:(NSString *)key;
+ (void)removeAllObject;

+ (NSNumber *)getSafeInt:(id)obj;
+ (NSNumber *)getSafeFloat:(id)obj;
+ (NSNumber *)getSafeBool:(id)obj;
+ (NSString *)getSafeString:(id)obj;

/// animation when switch uiviewcontroller
+ (void)transitionToViewController:(UIViewController *)viewController handler:(VoidBlock)block;

//check null nil
+ (BOOL)isNullOrNilObject:(id)object;
+(BOOL)checkNumbericWithString:(NSString*)str;

//File Manager
+ (NSString *)resourcePath:(NSString *)name;
+ (NSString *)documentPathComponent:(NSString*)strComponent;
+ (NSURL*)documentPath;
+ (void)deleteFilePath:(NSString*)strPath;
+ (void)saveImage:(UIImage*)image path:(NSString*)strPath;

//create images
+ (UIImage*)createImageBorderDashWithSize:(CGSize)size withColor:(UIColor*)color;
+ (UIImage*)createimageLineDashWithHeight:(CGFloat)height withColor:(UIColor*)color;
//Utilies
+ (void)showNetworkLoader:(BOOL)show;
+(NSString*)appendingDocumentPathComponent:(NSString*)strComponent;

//UUID
+(NSString*)createUUID;
+ (void)realmAddObject:(RLMObject *)object;
+ (void)realmDeleteAllObjects:(RLMResults*)results;
+ (void)realmDeleteObject:(RLMObject*)object;

//background

+ (CAGradientLayer*) bgGradient;
#pragma mark - Validate phone singapore

+(BOOL)checkPhoneNumber:(NSString*)phone;

#pragma mark - Pack size

+ (NSDictionary*)getInfoPackWithName:(NSString*)name;
+ (NSString*)convertStateOrder:(NSString*)state;
+ (NSString *)trimString:(NSString *)str;

+ (void)callTo:(NSString*)phone;

+ (void)downloadImage:(NSURL*)imageURL done:(void(^)(NSString *strImg))doneBlock;


@end
