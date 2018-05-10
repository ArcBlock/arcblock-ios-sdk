//
//  UIButton+ABSDKKVBinding.m
//  Pods
//
//  Created by Jonathan Lu on 16/11/2015.
//
//

#import "UIButton+ABSDKKVBinding.h"

@implementation UIButton (ABSDKKVBinding)

- (void)setTitle:(NSString*)title
{
    [self setTitle:title forState:UIControlStateNormal];
    NSLog(@"%@", [self titleForState:UIControlStateNormal]);
}

- (NSString*)title
{
    return [self titleForState:UIControlStateNormal];
}

@end
