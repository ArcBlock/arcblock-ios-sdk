//
//  ABSDKMeteorCollectionDataStore.m
//  Sprite
//
//  Created by Jonathan Lu on 5/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import "ABSDKDataStore.h"
#import <YapDatabase/YapDatabase.h>
#import "ABSDKDataStore+Private.h"

NSString *const ABSDKDataStoreModifiedNotification = @"ABSDKDataStoreModifiedNotification";

@interface ABSDKDataStore ()

@property (nonatomic, strong) NSArray *registeredCollections;

@property (nonatomic) BOOL dataStoreReady;
@property (nonatomic, strong) NSMutableDictionary *tempDataStore;
@property (nonatomic, strong) NSString *dbFileName;
@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *readConnection;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;

@property (nonatomic) NSMutableDictionary *dataStoreWillUpdateBlocks;
@property (nonatomic) NSMutableDictionary *dataStoreDidUpdateBlocks;
@property (nonatomic) NSMutableDictionary *dataStoreDidRemoveBlocks;

@end

@implementation ABSDKDataStore

+ (ABSDKDataStore *)sharedInstance
{
    static ABSDKDataStore *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ABSDKDataStore alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _registeredCollections = [NSMutableArray array];
        _dataStoreWillUpdateBlocks = [NSMutableDictionary dictionary];
        _dataStoreDidUpdateBlocks = [NSMutableDictionary dictionary];
        _dataStoreDidRemoveBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupDataStore:(NSString*)dbFileName
{
    if (!dbFileName) {
        dbFileName = @"tmp";
    }
    
    if (_dataStoreReady) {
        if ([dbFileName isEqualToString:_dbFileName]) {
            self.dataStoreReady = YES;
            return;
        }
        else {
            [self quitDataStore];
        }
    }
    
    _tempDataStore = [NSMutableDictionary dictionary];
    
    _dbFileName = dbFileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    _database = [[YapDatabase alloc] initWithPath:[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _dbFileName]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yapDatabaseModified:) name:YapDatabaseModifiedNotification object:_database];
    _readConnection = [_database newConnection];
    [_readConnection beginLongLivedReadTransaction];
    _writeConnection = [_database newConnection];
    
    self.dataStoreReady = YES;
}

- (void)quitDataStore
{
    if (!_dataStoreReady) {
        self.dataStoreReady = NO;
        return;
    }
    
    _tempDataStore = nil;
    
    _dbFileName = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _readConnection = nil;
    _writeConnection = nil;
    _database = nil;
    
    self.dataStoreReady = NO;
}

- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSArray *notifications = [_readConnection beginLongLivedReadTransaction];
    if (!notifications.count) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKDataStoreModifiedNotification object:nil userInfo:@{@"notifications": notifications}];
}


- (void)registerCollections:(NSArray *)collections
{
    _registeredCollections = [[NSSet setWithArray:[_registeredCollections arrayByAddingObjectsFromArray:collections]] allObjects];
}

- (BOOL)isRegisteredCollections:(NSString*)collection
{
    __block BOOL isRegistered = NO;
    [_registeredCollections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:collection]) {
            isRegistered = YES;
            *stop = YES;
        }
    }];
    return isRegistered;
}

- (void)setObject:(id)object forKey:(NSString*)key inCollection:(NSString *)collection completionBlock:(dispatch_block_t)completionBlock
{
    if (!key.length || !collection.length) {
        return;
    }
    
    if (![self isRegisteredCollections:collection]) {
        ABSDKDataStoreWillUpdateBlock willUpdateBlock = [_dataStoreWillUpdateBlocks objectForKey:collection];
        if (willUpdateBlock) {
            object = willUpdateBlock(collection, key, object);
        }
        NSMutableDictionary *collectionDict = [NSMutableDictionary dictionaryWithDictionary:_tempDataStore[collection]];
        if ([[collectionDict objectForKey:key] isEqual:object]) {
            if (completionBlock) {
                completionBlock();
            }
            return;
        }
        [collectionDict setObject:object forKey:key];
        [_tempDataStore setObject:collectionDict forKey:collection];
        [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKDataStoreModifiedNotification object:nil userInfo:@{@"inMemory":@(YES), @"notifications": @[@{@"collection": collection, @"key":key, @"object": object}]}];
        // perform post-update actions in data store level
        ABSDKDataStoreDidUpdateBlock didUpdateBlock = [_dataStoreDidUpdateBlocks objectForKey:collection];
        if (didUpdateBlock) {
            didUpdateBlock(collection, key, object);
        }
        if (completionBlock) {
            completionBlock();
        }
    }
    else {
        __weak typeof(self) wself = self;
        [_writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            id oldObject = [transaction objectForKey:key inCollection:collection];
            
            ABSDKDataStoreWillUpdateBlock willUpdateBlock = [wself.dataStoreWillUpdateBlocks objectForKey:collection];
            id objectToUpdate;
            if (willUpdateBlock) {
                objectToUpdate = willUpdateBlock(collection, key, object);
            }
            else {
                objectToUpdate = object;
            }
            
            if ([objectToUpdate isEqual:oldObject]) {
                return;
            }
            
            transaction.yapDatabaseModifiedNotificationCustomObject = objectToUpdate;
            [transaction setObject:objectToUpdate forKey:key inCollection:collection];
        } completionBlock:^{
            // perform post-update actions in data store level
            ABSDKDataStoreDidUpdateBlock didUpdateBlock = [wself.dataStoreDidUpdateBlocks objectForKey:collection];
            if (didUpdateBlock) {
                didUpdateBlock(collection, key, object);
            }
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
}

- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection completionBlock:(dispatch_block_t)completionBlock
{
    if (![self isRegisteredCollections:collection]) {
        NSMutableDictionary *collectionToRemoveObject = [NSMutableDictionary dictionaryWithDictionary:[_tempDataStore objectForKey:collection]];
        if ([collectionToRemoveObject objectForKey:key]) {
            [collectionToRemoveObject removeObjectForKey:key];
            [_tempDataStore setObject:collectionToRemoveObject forKey:collection];
            [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKDataStoreModifiedNotification object:nil userInfo:@{@"inMemory":@(YES), @"notifications": @[@{@"collection": collection, @"key":key}]}];
            ABSDKDataStoreDidRemoveBlock didRemoveBlock = [_dataStoreDidRemoveBlocks objectForKey:collection];
            if (didRemoveBlock) {
                didRemoveBlock(collection, key);
            }
            if (completionBlock) {
                completionBlock();
            }
        }
    }
    else {
        __weak typeof(self) wself = self;
        [_writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            if ([transaction objectForKey:key inCollection:collection]) {
                if ([collection isEqualToString:@"message"]) {
                    NSDictionary *transactionExtendedInfo = @{@"deleteMessage": key};
                    transaction.yapDatabaseModifiedNotificationCustomObject = transactionExtendedInfo;
                }
                [transaction removeObjectForKey:key inCollection:collection];
            }
        } completionBlock:^{
            ABSDKDataStoreDidRemoveBlock didRemoveBlock = [wself.dataStoreDidRemoveBlocks objectForKey:collection];
            if (didRemoveBlock) {
                didRemoveBlock(collection, key);
            }
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
}

- (id)objectForKey:(NSString*)key inCollection:(NSString*)collection
{
    __block id result;
    if (![self isRegisteredCollections:collection]) {
        result = [[_tempDataStore objectForKey:collection] objectForKey:key];
    }
    else {
        [_readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            result = [transaction objectForKey:key inCollection:collection];
        }];
    }
    return result;
}

- (void)enumerateKeysAndObjectsInCollection:(nullable NSString *)collection usingBlock:(void (^)(NSString *key, id object, BOOL *stop))block
{
    if (![self isRegisteredCollections:collection]) {
        NSDictionary *collectionDictionary = [_tempDataStore objectForKey:collection];
        [collectionDictionary enumerateKeysAndObjectsUsingBlock:block];
    }
    else {
	[_readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            [transaction enumerateKeysAndObjectsInCollection:collection usingBlock:block];
        }];
    }
}

- (NSArray*)allKeysInCollection:(NSString*)collection
{
    __block id result;
    if (![self isRegisteredCollections:collection]) {
        result = [[_tempDataStore objectForKey:collection] allKeys];
    }
    else {
        [_readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            result = [transaction allKeysInCollection:collection];
        }];
    }

    return result;
}

- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection notification:(NSNotification *)notification
{
    NSArray *notifications = notification.userInfo[@"notifications"];
    BOOL inMemory = [notification.userInfo[@"inMemory"] boolValue];
    if ([self isRegisteredCollections:collection]) {
        return !inMemory && [_readConnection hasChangeForKey:key inCollection:collection inNotifications:notifications];
    }
    else {
        if (inMemory) {
            for (NSDictionary *notification in notifications) {
                if ([notification[@"collection"] isEqualToString:collection] && [notification[@"key"] isEqualToString:key]) {
                    return YES;
                }
            }
        }
        return NO;
    }
}

@end
