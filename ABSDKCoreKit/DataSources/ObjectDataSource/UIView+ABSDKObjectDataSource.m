//
//  UIView+KVBinding.m
//  PixoClub
//
//  Created by Robert Mao on 1/7/14.
//  Copyright (c) 2014 LOCQL INC. All rights reserved.
//

#import "UIView+ABSDKObjectDataSource.h"
#import <objc/runtime.h>

static char const * const UndefinedObjectsDictKey = "UndefinedObjectsDict";

@implementation UIView (ABSDKObjectDataSource)

- (void)observeObjectDataSource:(ABSDKObjectDataSource*)objectDataSource updatedBlock:(void (^)(void))updatedBlock
{
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:ABSDKObjectDataSourceDidUpdateNotification object:objectDataSource queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        [wself updateWithObject:[objectDataSource fetchObject]];
        if (updatedBlock) {
            updatedBlock();
        }
    }];
}

#pragma mark - Overrides

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // see if the UndefinedObjects dictionary exists, if not, create it
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
    }
    else {
        undefinedDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, UndefinedObjectsDictKey, undefinedDict, OBJC_ASSOCIATION_RETAIN);
    }
    [undefinedDict setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
        return [undefinedDict valueForKey:key];
    }
    else {
        return nil;
    }
}

#pragma mark - Public Methods

- (void)bind:(NSString*)viewKey objectKey:(NSString*)objectKey
{
    [self setValue:objectKey forKey:[NSString stringWithFormat:@"bind%@", viewKey]];
}

- (void)updateWithObject:(id)object
{
    // first check ourselves for any bindable properties. Then process our
    // children.
    NSArray *undefinedKeys = [self undefinedKeys];
    if ( undefinedKeys ) {
        for ( NSString *key in undefinedKeys ) {
            // only bind things that start with the lowercase bind string
            if ( ( [key length] > 4 ) && [[key substringToIndex:4] isEqualToString:@"bind"] ) {
                
                NSString *keyToBind = [key substringFromIndex:4];
                NSString *keyValue = [self valueForKey:key];
                
                id value = [object valueForKey:keyValue];

                // Value could be NSNull returned from object model, we also treat it as nil
                if (value != nil && value != [NSNull null]) {
                    [self setValue:value forKey:keyToBind];
                }
                else {
                    //NSLog(@"Binding Error: %@ don't have value for key:%@", obj, keyValue);
                    [self setValue:nil forKey:keyToBind];
                }
            }
        }
    }
    
    for ( UIView *subview in [self subviews] ) {
        [subview updateWithObject:object];
    }
}

#pragma mark - Private Methods
- (NSArray *)undefinedKeys {
    if ( objc_getAssociatedObject(self, UndefinedObjectsDictKey) ) {
        NSDictionary *undefinedDict = objc_getAssociatedObject(self, UndefinedObjectsDictKey);
        return [undefinedDict allKeys];
    }
    else {
        return nil;
    }
}

@end
