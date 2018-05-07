//
//  ABSDKArrayDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 4/9/2016.
//
//

#import <UIKit/UIKit.h>
#import "ABSDKArrayDataSource.h"

NSString *const ABSDKArrayDataSourceDidUpdateNotification = @"ABSDKArrayDataSourceDidUpdateNotification";

@implementation ABSDKArrayDataSource

- (id)initWithArray:(NSArray*) array
{
    self = [super init];
    
    if (self) {
        [self setArray:array];
    }
    
    return self;
}

- (void)setArray:(NSArray *)array
{
    _array = array;
    [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKArrayDataSourceDidUpdateNotification object:self];
}

- (NSInteger) numberOfSections
{
    if ([_array.firstObject isKindOfClass:[NSArray class]]) {
        return _array.count;
    }
    else {
        return 1;
    }
}

- (NSInteger) numberOfItemsForSection:(NSInteger)section
{
    if ([_array.firstObject isKindOfClass:[NSArray class]]) {
        NSArray *subarray = _array[section];
        return subarray.count;
    }
    else {
        return _array.count;
    }
}

- (id) getItemAtIndextPath:(NSIndexPath*)indexPath
{
    if ([_array.firstObject isKindOfClass:[NSArray class]]) {
        if ((indexPath.section >=0) && (indexPath.section < [_array count])) {
            NSArray *subarray = _array[indexPath.section];
            if ((indexPath.row >=0) && (indexPath.row < [subarray count])) {
                return subarray[indexPath.row];
            }
        }
    }
    else {
        if ((indexPath.row >=0) && (indexPath.row < [_array count])) {
            return _array[indexPath.row];
        }
    }
    
    return nil;
}

- (BOOL)isEmpty
{
    if ([_array.firstObject isKindOfClass:[NSArray class]]) {
        NSInteger count = 0;
        for (NSArray *subarray in _array) {
            count += subarray.count;
        }
        return count == 0;
    }
    else {
        return _array.count == 0;
    }
}

- (void)loadData
{
    
}

- (void) refresh
{
    
}

- (void) loadMore
{
    
}

- (void) removeAll
{
    
}

- (void) remove:(NSIndexPath*)indexPath
{
    
}

@end
