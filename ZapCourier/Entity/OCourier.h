//
//  OCourier.h
//  Delivery
//
//  Created by Long Nguyen on 12/28/15.
//  Copyright © 2015 Long Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCourierPosition.h"

@interface OCourier : NSObject

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) OCourierPosition *tail;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *photo;

@end
