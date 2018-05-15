//
//  UIImageView+KVBinding.m
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import "UIImageView+ABSDKObjectDataSource.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (ABSDKObjectDataSource)

- (void)setImageUrl:(NSString *)imageUrl
{
    if (![imageUrl isEqual:[NSNull null]] && imageUrl.length) {
        [self sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
    else {
        self.image = nil;
    }
}

- (NSString*)imageUrl
{
    return nil;
}

@end
