//
//  HNRefreshHelper.h
//  testPopup
//
//  Created by Long Nguyen on 4/26/16.
//  Copyright © 2016 Long Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingHelper : NSObject{
    UIView *viewContainer;
    UIView *viewBg;
    UIImageView *imvLoading;
}

+ (LoadingHelper *)shared;

- (void)loadingWithView:(UIView*)view;

- (void)loading;
- (void)removeLoading;

@end
