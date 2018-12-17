//
//  Utils.m
//  NewProject
//
//  Created by Long Nguyen on 4/11/14.
//  Copyright (c) 2014 Long Nguyen. All rights reserved.
//

#import "Util.h"
#import "Macros.h"
#import "AppDelegate.h"
#import "KLCPopup.h"

#define IPAD_XIB_POSTFIX @"~iPad"


@implementation Util

#pragma mark - get XIB
+ (NSString *)getXIB:(Class)fromClass {
    NSString *className = NSStringFromClass(fromClass);
    
    if (IS_IPAD) {
        className = [className stringByAppendingString:IPAD_XIB_POSTFIX];
    }
    else {
    }
    return className;
}

+ (void)fixDownyView:(id)viewController {
    float fVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (fVersion >= 7) {
        ((UIViewController *)viewController).automaticallyAdjustsScrollViewInsets = NO;
        ((UIViewController *)viewController).edgesForExtendedLayout = UIRectEdgeNone;
    }
}

+ (Util *)sharedUtil {
    static Util *_sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtil = [[Util alloc] init];
    });
    
    return _sharedUtil;
}

+ (AppDelegate *)appDelegate {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate;
}

+ (id)initWithXib:(NSString*)name {
    return [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
}

+ (id)initViewController:(Class)classView storyboard:(NSString*)strStoryboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:strStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(classView)];
}

#pragma mark - Loading View

- (void)showLoading {
    [[LoadingHelper shared] loading];
    [Util showNetworkLoader:YES];
}

- (void)showLoadingView:(UIView*)view {
    [[LoadingHelper shared] loadingWithView:view];
    [Util showNetworkLoader:YES];
}

- (void)hideLoading {
    [Util showNetworkLoader:NO];
    [[LoadingHelper shared] removeLoading];
}

#pragma mark - Switch View

+ (void)transitionToViewController:(UIViewController *)viewController handler:(VoidBlock)block{
    [UIView transitionFromView:APPSHARE.window.rootViewController.view
                        toView:viewController.view
                      duration:0.65f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished){
                        block();
                    }];
}

#pragma mark - Currency

+(NSString*)formatCurrencyWithNumber:(NSString*)number withSymbol:(NSString*)symbol{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setCurrencySymbol:symbol];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:number.doubleValue]];
}
+(BOOL) NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
#pragma mark - Get Safe Data
#pragma mark - Font

+ (void)printAllSystemFonts{
    printf("--------------------------------------------------------------------\n");
    NSArray *familyNames = [UIFont familyNames];
    for( NSString *familyName in familyNames ){
        printf( "Family: %s \n", [familyName UTF8String] );
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for( NSString *fontName in fontNames ){
            printf( "\tFont: %s \n", [fontName UTF8String] );
        }
    }
    printf("--------------------------------------------------------------------\n");
}

#pragma mark - Null or nil

+ (BOOL)isNullOrNilObject:(id)object
{
    if ([object isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (object == nil) {
        return YES;
    }
    return NO;
}

#pragma mark - Object

+ (void)setValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    [[NSUserDefaults standardUserDefaults] setValue:value forKeyPath:keyPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setObject:(id)obj forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)valueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (id)valueForKeyPath:(NSString *)keyPath {
    return [[NSUserDefaults standardUserDefaults] valueForKeyPath:keyPath];
}

+ (id)objectForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)removeObjectForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeAllObject {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+ (NSNumber *)getSafeInt:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj length] == 0) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    return [NSNumber numberWithInt:[obj intValue]];
}

+ (NSNumber *)getSafeFloat:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj length] == 0) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    return [NSNumber numberWithFloat:[obj floatValue]];
}

+ (NSNumber *)getSafeBool:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if ([obj length] == 0) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [NSNumber numberWithInt:INT_MIN];
    }
    return [NSNumber numberWithBool:[obj boolValue]];
}

+ (NSString *)getSafeString:(id)obj {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    return [obj stringValue];
}

+(BOOL)checkNumbericWithString:(NSString*)str{
    NSScanner *scanner = [NSScanner scannerWithString:str];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    return isNumeric;
}
#pragma mark - File Manager

+ (NSString *)resourcePath:(NSString *)name {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@", name];
}

+ (NSString *)documentPathComponent:(NSString *)strComponent {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:strComponent];
}

+ (NSURL*)documentPath {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (void)deleteFilePath:(NSString*)strPath {
    dispatch_async(BGQueue, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
        }
    });
}

+ (void)saveImage:(UIImage*)image path:(NSString*)strPath {
    dispatch_async(BGQueue, ^{
        NSData *imageData = UIImagePNGRepresentation(image);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
        }
        [imageData writeToFile:strPath atomically:YES];
    });
}

#pragma mark - border

+ (UIImage*)createImageBorderDashWithSize:(CGSize)size withColor:(UIColor*)color{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 4.0);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGFloat dashArray[] = {6,2,6,2};
    
    CGContextSetLineDash(context,3, dashArray, 1);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddQuadCurveToPoint(context, 0, 0, size.width, 0);
    
    CGContextMoveToPoint(context, size.width, 0);
    CGContextAddQuadCurveToPoint(context, size.width, 0, size.width, size.height);
    
    CGContextMoveToPoint(context, size.width, size.height);
    CGContextAddQuadCurveToPoint(context, size.width, size.height, 0, size.height);
    
    CGContextMoveToPoint(context, 0, size.height);
    CGContextAddQuadCurveToPoint(context, 0, size.height, 0, 0);
    
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)createimageLineDashWithHeight:(CGFloat)height withColor:(UIColor*)color{
    UIGraphicsBeginImageContext(CGSizeMake(2, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGFloat dashArray[] = {2,2,2,2};
    
    CGContextSetLineDash(context, 3, dashArray, 2);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddQuadCurveToPoint(context, 0, 0, 0, height);
    
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


#pragma mark - Utilies

+ (void)showNetworkLoader:(BOOL)show {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
}

+(NSString*)appendingDocumentPathComponent:(NSString*)strComponent{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:strComponent];
}

#pragma mark - UUID

#pragma mark - create UUID
+(NSString*)createUUID{
    if ([self isNullOrNilObject:[self objectForKey:@"UUID"]]) {
        [self setObject:[[NSUUID UUID] UUIDString] forKey:@"UUID"];
        return [self objectForKey:@"UUID"];
    }else{
        return [self objectForKey:@"UUID"];
    }
}

+ (void)realmAddObject:(RLMObject *)object {
    if (object) {
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        [defaultRealm transactionWithBlock:^{
            [defaultRealm addOrUpdateObject:object];
        }];
    }
}

+ (void)realmDeleteAllObjects:(RLMResults*)results {
    if (results.count) {
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        [defaultRealm transactionWithBlock:^{
            [defaultRealm deleteObjects:results];
        }];
    }
}

+ (void)realmDeleteObject:(RLMObject*)object {
    if (object) {
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        [defaultRealm beginWriteTransaction];
        [defaultRealm deleteObject:object];
        [defaultRealm commitWriteTransaction];
    }
}


+(void)clearCacheImage{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}
#pragma mark - Background gradient

+ (CAGradientLayer*) bgGradient {
    
    UIColor *colorOne = UIColorFromRGB(0xfff659);
    UIColor *colorTwo = UIColorFromRGB(0xffd04e);
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
    
}

#pragma mark - Validate phone singapore

+(BOOL)checkPhoneNumber:(NSString*)phone{
    if (phone.length!=8) {
        return NO;
    }
    if (![self checkNumbericWithString:phone]) {
        return NO;
    }
    NSString *subString = [phone substringToIndex:1];
    if (![subString isEqualToString:@"8"] && ![subString isEqualToString:@"9"]) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Pack size

+(NSDictionary*)getInfoPackWithName:(NSString*)name{
    if ([[name uppercaseString] isEqualToString:@"DOCUMENT"]) {
        return @{@"pack":@"DOCUMENT",
                 @"size":@"Size: 10-20 cm",
                 @"weight":@"Weight: 1 kg",
                 @"guide":@"Use small when each dimension of your package reaches 1 kg.",
                 @"image":@"icon_document"};
    }else if ([[name uppercaseString] isEqualToString:@"PARCEL"]) {
        return @{@"pack":@"PARCEL",
                 @"size":@"Size: 10-20 cm",
                 @"weight":@"Weight: 10 kg",
                 @"guide":@"Use small when each dimension of your package reaches 10 kg.",
                 @"image":@"icon_parcel"};
    }else{
        return nil;
    }
}


+ (NSString*)convertStateOrder:(NSString*)state{
    if ([state isEqualToString:stateKeyAssigning]) {
        return stateValueAssigning;
    }else if ([state isEqualToString:stateKeyCancelled]) {
        return stateValueCancelled;
    }else if ([state isEqualToString:stateKeyAccepted]) {
        return statevalueAccepted;
    }else if ([state isEqualToString:stateKeyDelivery]) {
        return stateValueDelivery;
    }else if ([state isEqualToString:stateKeyCompleted]) {
        return stateValueCompleted;
    }else if ([state isEqualToString:stateKeyCourierCancelled]) {
        return stateValueCourierCancelled;
    }else if ([state isEqualToString:stateValueAdminCancelled]) {
        return stateValueAdminCancelled;
    }else if ([state isEqualToString:stateKeyReturning]) {
        return stateValueReturning;
    }else if ([state isEqualToString:stateKeyReturned]) {
        return stateValueReturned;
    }else if ([state isEqualToString:stateKeyInOffice]) {
        return stateValueInOffice;
    }else if ([state isEqualToString:stateKeyBackDelivery]) {
        return stateValueBackDelivery;
    }else if ([state isEqualToString:stateKeyBackFailure]) {
        return stateValueBackFailure;
    }else if ([state isEqualToString:stateKeyWaiting]) {
        return stateValueWaiting;
    }else if ([state isEqualToString:stateKeyBackReturned]) {
        return stateValueBackReturned;
    }else if ([state isEqualToString:stateKeyBackReturning]){
        return stateKeyBackReturning;
    }else if ([state isEqualToString:stateKeyAdminCancelled]) {
        return stateValueAdminCancelled;
    }else{
        return @"";
    }
}

+ (NSString *)trimString:(NSString *)str {
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmedString;
}

+ (void)callTo:(NSString*)phone{
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",phone]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)downloadImage:(NSURL*)imageURL done:(void(^)(NSString *strImg))doneBlock {
    //    dispatch_async(SVQueue, ^{
    NSData * data = [[NSData alloc] initWithContentsOfURL:imageURL];
    if ( data == nil ) {
        doneBlock(@"");
    }else{
        UIImage *img = [UIImage imageWithData:data];
        float ratioW = 50/img.size.width;
        NSData *dataConvert = UIImageJPEGRepresentation([self convertToSize:CGSizeMake(img.size.width*ratioW, img.size.height*ratioW) withImage:img], 1);
        //            dispatch_async(MainQueue, ^{
        doneBlock([dataConvert base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
        //            });
    }
    //    });
}
+ (UIImage *)convertToSize:(CGSize)size withImage:(UIImage*)img{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


@end
