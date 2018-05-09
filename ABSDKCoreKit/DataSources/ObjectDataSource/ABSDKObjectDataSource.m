//
//  ABSDKView.m
//  Sprite
//
//  Created by Jonathan Lu on 12/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import "ABSDKObjectDataSource.h"
#import "ABSDKDataStore.h"
#import <KVOController/KVOController.h>

@interface ABSDKObjectDataSource ()

@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) NSString *collection;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) BOOL updated;

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
            wself.updated = YES;
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreModified:) name:ABSDKDataStoreModifiedNotification object:nil];
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
        NSLog(@"data source updated: %@, %@", _collection, _key);
        self.updated = YES;
    }
}

- (id)fetchObject{
    return [[ABSDKDataStore sharedInstance] objectForKey:_key inCollection:_collection];
}

@end
