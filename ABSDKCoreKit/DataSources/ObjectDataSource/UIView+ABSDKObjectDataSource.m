// UIView+ABSDKObjectDataSource.m
//
// Copyright (c) 2017-present ArcBlock Foundation Ltd <https://www.arcblock.io/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

- (void)updateWithObject:(NSDictionary*)object
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
