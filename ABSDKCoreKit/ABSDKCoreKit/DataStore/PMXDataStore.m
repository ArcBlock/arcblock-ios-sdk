//
//  PMXMeteorCollectionDataStore.m
//  Sprite
//
//  Created by Jonathan Lu on 5/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import "PMXDataStore.h"
#import <FBKVOController.h>

NSString *const PMXDataStoreModifiedNotification = @"PMXDataStoreModifiedNotification";

typedef NS_ENUM(NSInteger, PMXDataStoreType) {
    PMXDataStoreTypeNone        = 0,
    PMXDataStoreInMemory        = 1,
    PMXDataStoreInDatabase      = 2,
};

@interface PMXDataStore ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) NSMutableDictionary *tempDataStore;
@property (nonatomic, strong) NSString *dbFileName;

@end

@implementation PMXDataStore

+ (PMXDataStore *)sharedInstance
{
    static PMXDataStore *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PMXDataStore alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _collectionsInMemory = [NSMutableArray array];
        _collectionsInDatabase = [NSMutableArray array];
        _kvoController = [FBKVOController controllerWithObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupDataStore:(NSString*)dbFileName
{
    if (_database) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    _dbFileName = dbFileName;
    if (!_dbFileName) {
        _dbFileName = @"tmp";
    }
    _database = [[YapDatabase alloc] initWithPath:[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _dbFileName]]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yapDatabaseModified:) name:YapDatabaseModifiedNotification object:_database];
    _writeConnection = [_database newConnection];
    
    _readConnection = [_database newConnection];
    [_readConnection beginLongLivedReadTransaction];
    
    _tempDataStore = [NSMutableDictionary dictionary];
    
    _dataStoreWillUpdateBlocks = [NSMutableDictionary dictionary];
    _dataStoreDidUpdateBlocks = [NSMutableDictionary dictionary];
    _dataStoreDidRemoveBlocks = [NSMutableDictionary dictionary];
    
    self.dataStoreReady = YES;
}

- (void)quitDataStore
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _database = nil;
    _writeConnection = nil;
    _readConnection = nil;
    
    _tempDataStore = nil;
    
    _dataStoreWillUpdateBlocks = nil;
    _dataStoreDidUpdateBlocks = nil;
    _dataStoreDidRemoveBlocks = nil;
    
    self.dataStoreReady = NO;
}

- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSArray *notifications = [_readConnection beginLongLivedReadTransaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:PMXDataStoreModifiedNotification object:nil userInfo:@{@"notifications": notifications}];
}

- (PMXDataStoreType)dataStoreTypeForCollection:(NSString*)collection
{
    for (NSString *collectionName in _collectionsInMemory) {
        if ([collectionName isEqualToString:collection]) {
            return PMXDataStoreInMemory;
        }
    }
    
    for (NSString *collectionName in _collectionsInDatabase) {
        if ([collectionName isEqualToString:collection]) {
            return PMXDataStoreInDatabase;
        }
    }
    
    return PMXDataStoreTypeNone;
}

- (void)registerExtension:(id)extension withName:(NSString*)name completionBlock:(void(^)(BOOL ready))completionBlock
{
    [_database asyncRegisterExtension:extension withName:name completionBlock:completionBlock];
}

- (void)unregisterExtensionWithName:(NSString*)name
{
    [_database asyncUnregisterExtensionWithName:name completionBlock:nil];
}

- (void)setObject:(id)object forKey:(NSString*)key inCollection:(NSString *)collection
{
    if (!key.length || !collection.length) {
        return;
    }
    PMXDataStoreType type = [self dataStoreTypeForCollection:collection];
    
    // modify object before store
    if (type == PMXDataStoreInMemory) {
        PMXDataStoreWillUpdateBlock willUpdateBlock = [_dataStoreWillUpdateBlocks objectForKey:collection];
        if (willUpdateBlock) {
            object = willUpdateBlock(collection, key, object);
        }
        NSMutableDictionary *collectionDict = [NSMutableDictionary dictionaryWithDictionary:_tempDataStore[collection]];
        if ([[collectionDict objectForKey:key] isEqual:object]) {
            return;
        }
        [collectionDict setObject:object forKey:key];
        [_tempDataStore setObject:collectionDict forKey:collection];
        [[NSNotificationCenter defaultCenter] postNotificationName:PMXDataStoreModifiedNotification object:nil userInfo:@{@"collection": collection, @"key":key, @"object": object}];
        // perform post-update actions in data store level
        PMXDataStoreDidUpdateBlock didUpdateBlock = [_dataStoreDidUpdateBlocks objectForKey:collection];
        if (didUpdateBlock) {
            didUpdateBlock(collection, key, object);
        }
    }
    else if (type == PMXDataStoreInDatabase) {
        __weak typeof(self) wself = self;
        [_writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            id oldObject = [transaction objectForKey:key inCollection:collection];
            
            PMXDataStoreWillUpdateBlock willUpdateBlock = [wself.dataStoreWillUpdateBlocks objectForKey:collection];
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
            PMXDataStoreDidUpdateBlock didUpdateBlock = [wself.dataStoreDidUpdateBlocks objectForKey:collection];
            if (didUpdateBlock) {
                didUpdateBlock(collection, key, object);
            }
        }];
    }
}

- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection
{
    PMXDataStoreType type = [self dataStoreTypeForCollection:collection];
    if (type == PMXDataStoreInMemory) {
        NSMutableDictionary *collectionToRemoveObject = [NSMutableDictionary dictionaryWithDictionary:[_tempDataStore objectForKey:collection]];
        if ([collectionToRemoveObject objectForKey:key]) {
            [collectionToRemoveObject removeObjectForKey:key];
            [_tempDataStore setObject:collectionToRemoveObject forKey:collection];
            [[NSNotificationCenter defaultCenter] postNotificationName:PMXDataStoreModifiedNotification object:nil userInfo:@{@"inMemory":@(YES), @"collection": collection, @"key":key}];
            PMXDataStoreDidRemoveBlock didRemoveBlock = [_dataStoreDidRemoveBlocks objectForKey:collection];
            if (didRemoveBlock) {
                didRemoveBlock(collection, key);
            }
        }
    }
    else if (type == PMXDataStoreInDatabase) {
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
            PMXDataStoreDidRemoveBlock didRemoveBlock = [wself.dataStoreDidRemoveBlocks objectForKey:collection];
            if (didRemoveBlock) {
                didRemoveBlock(collection, key);
            }
        }];
    }
}

- (id)objectForKey:(NSString*)key inCollection:(NSString*)collection
{
    PMXDataStoreType type = [self dataStoreTypeForCollection:collection];
    
    __block id result;
    if (type == PMXDataStoreInMemory) {
        result = [[_tempDataStore objectForKey:collection] objectForKey:key];
    }
    else if (type == PMXDataStoreInDatabase) {
        [_readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            result = [transaction objectForKey:key inCollection:collection];
        }];
    }
    return result;
}

- (void)enumerateKeysAndObjectsInCollection:(nullable NSString *)collection usingBlock:(void (^)(NSString *key, id object, BOOL *stop))block
{
    PMXDataStoreType type = [self dataStoreTypeForCollection:collection];
    
    if (type == PMXDataStoreInMemory) {
        NSDictionary *collectionDictionary = [_tempDataStore objectForKey:collection];
        [collectionDictionary enumerateKeysAndObjectsUsingBlock:block];
    }
    else if (type == PMXDataStoreInDatabase) {
	[_readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            [transaction enumerateKeysAndObjectsInCollection:collection usingBlock:block];
        }];
    }
}

- (NSArray*)allKeysInCollection:(NSString*)collection
{
    PMXDataStoreType type = [self dataStoreTypeForCollection:collection];
    
    __block id result;
    if (type == PMXDataStoreInMemory) {
        result = [[_tempDataStore objectForKey:collection] allKeys];
    }
    else if (type == PMXDataStoreInDatabase) {
        [_readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            result = [transaction allKeysInCollection:collection];
        }];
    }

    return result;
}

- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection inNotifications:(NSArray *)notifications
{
    return [_readConnection hasChangeForKey:key inCollection:collection inNotifications:notifications];
}

@end
