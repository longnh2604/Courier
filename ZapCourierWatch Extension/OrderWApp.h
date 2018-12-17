#import <Foundation/Foundation.h>

@interface OrderWApp : NSObject

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderPrice;
@property (nonatomic, strong) NSString *orderPickup;
@property (nonatomic, strong) NSString *orderDropoff;
@property (nonatomic, strong) NSString *orderReturn;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)eventsList:(NSArray *)data;

@end
