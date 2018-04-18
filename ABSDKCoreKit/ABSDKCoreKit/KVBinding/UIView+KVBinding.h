//
//  UIView+KVBinding.h
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KVBinding)

+ (UIView*) viewFromNib:(NSString*)nibName;

- (void)bindWithObject:(id)obj;

@end

@interface UIBarButtonItem (KVBinding)


@end