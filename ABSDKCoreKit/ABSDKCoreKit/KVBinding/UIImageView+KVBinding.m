//
//  UIImageView+KVBinding.m
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import "UIImageView+KVBinding.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (KVBinding)

- (void)setImageUrl:(NSString *)imageUrl
{
    if (![imageUrl isEqual:[NSNull null]] && imageUrl.length) {
        [self sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
}

- (NSString*)imageUrl
{
    return nil;
}

@end
