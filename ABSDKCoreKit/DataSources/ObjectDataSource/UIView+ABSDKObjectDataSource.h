//
//  UIView+KVBinding.h
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+ABSDKObjectDataSource.h"
#import "UIButton+ABSDKObjectDataSource.h"
#import "ABSDKObjectDataSource.h"

@interface UIView (ABSDKObjectDataSource)

- (void)bind:(NSString*)viewKey objectKey:(NSString*)objectKey;
- (void)observeObjectDataSource:(ABSDKObjectDataSource*)objectDataSource updatedBlock:(void (^)(void))updatedBlock;
- (void)updateWithObject:(id)object;

@end
