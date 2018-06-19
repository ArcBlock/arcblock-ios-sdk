// ABSDKObjectDataSource.m
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

#import "ABSDKObjectDataSource.h"
#import "ABSDKDataStore.h"
#import <KVOController/KVOController.h>

NSString *const ABSDKObjectDataSourceDidUpdateNotification = @"ABSDKObjectDataSourceDidUpdateNotification";

@interface ABSDKObjectDataSource ()

@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) NSString *collection;
@property (nonatomic, strong) NSString *key;

@end

@implementation ABSDKObjectDataSource

+ (ABSDKObjectDataSource*)objectDataSourceWithCollection:(NSString*)collection key:(NSString*)key
{
    static NSMutableDictionary *dataSources = nil;
    if (dataSources == nil) {
        dataSources = [NSMutableDictionary dictionary];
    }
    NSString *index = [NSString stringWithFormat:@"%@.%@", collection, key];
    ABSDKObjectDataSource *dataSource = dataSources[index];
    if (!dataSource) {
        dataSource = [[self alloc] initWithCollection:collection key:key];
        [dataSources setObject:dataSource forKey:index];
    }
    return dataSource;
}

- (id)initWithCollection:(NSString*)collection key:(NSString*)key
{
    self = [super init];
    if (self) {
        _collection = collection;
        _key = key;
        _kvoController = [FBKVOController controllerWithObserver:self];
        __weak typeof(self) wself = self;
        [_kvoController observe:[ABSDKDataStore sharedInstance] keyPath:@"dataStoreReady" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKObjectDataSourceDidUpdateNotification object:wself];
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreModified:) name:ABSDKDataStoreModifiedNotification object:[ABSDKDataStore sharedInstance]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataStoreModified:(NSNotification *)notification
{
    if ([[ABSDKDataStore sharedInstance] hasChangeForKey:_key inCollection:_collection notification:notification]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKObjectDataSourceDidUpdateNotification object:self];
    }
}

- (NSDictionary*)fetchObject{
    return [[ABSDKDataStore sharedInstance] objectForKey:_key inCollection:_collection];
}

@end
