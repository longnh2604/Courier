#import "OrderWApp.h"

@implementation OrderWApp
@synthesize orderId,orderPrice,orderDropoff,orderPickup,orderReturn;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self)
    {
        orderId = dictionary[@"orderId"];
        orderPrice = dictionary[@"orderPrice"];
        orderPickup = dictionary[@"orderPickup"];
        orderDropoff = dictionary[@"orderDropoff"];
        orderReturn = dictionary[@"orderReturn"];
    }
    
    return self;
}

+ (NSArray *)eventsList:(NSArray *)data
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *e in data)
    {
        OrderWApp *event = [[OrderWApp alloc] initWithDictionary:e];
        [array addObject:event];
    }
    
    return array;
}

@end
