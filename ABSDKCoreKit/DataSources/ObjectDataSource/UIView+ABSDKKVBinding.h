//
//  UIView+KVBinding.h
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+ABSDKKVBinding.h"
#import "UIButton+ABSDKKVBinding.h"

@interface UIView (ABSDKKVBinding)

- (void)bind:(NSString*)viewKey objectKey:(NSString*)objectKey;
- (void)updateWithObject:(id)object;

@end
