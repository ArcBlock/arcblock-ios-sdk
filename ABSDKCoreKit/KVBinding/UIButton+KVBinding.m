//
//  UIButton+KVBinding.m
//  Pods
//
//  Created by Jonathan Lu on 16/11/2015.
//
//

#import "UIButton+KVBinding.h"

@implementation UIButton (KVBinding)

- (void)setTitle:(NSString*)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

@end
