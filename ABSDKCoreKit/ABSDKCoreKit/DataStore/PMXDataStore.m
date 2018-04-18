//
//  PMXMeteorCollectionDataStore.m
//  Sprite
//
//  Created by Jonathan Lu on 5/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import "PMXDataStore.h"

#import "YapDatabaseView.h"
#import <FBKVOController.h>
#import <YapDatabaseSearchResultsView.h>

NSString *const PMXDataStoreModifiedNotification = @"PMXDataStoreModifiedNotification";
NSString *const PMXDataStoreCustomKey = @"custom";

typedef NS_ENUM(NSInteger, PMXDataStoreType) {
    PMXDataStoreTypeNone        = 0,
    PMXDataStoreInMemory        = 1,
    PMXDataStoreInDatabase      = 2,
};

@interface PMXDataStore ()

@property (nonatomic, strong) YapDatabaseConnection *searchConnection;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;
@property (nonatomic, strong) YapDatabaseConnection *readConnection;
@property (nonatomic, strong) YapDatabaseConnection *enumerateConnection;
@property (nonatomic, strong) YapDatabaseSearchQueue *searchQueue;
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) NSMutableDictionary *tempDataStore;
@property (nonatomic, strong) NSString *filePath;

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
        [self setupDatabase];
        _kvoController = [FBKVOController controllerWithObserver:self];
        __weak typeof(self) wself = self;
//        [_kvoController observe:[PMXAuth sharedInstance] keyPath:CURREENT_USERID_KEY_PATH options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//            NSLog(@"%@", change);
//            [wself currentUserChanged];
//        }];
    }
    return self;
}

- (void)currentUserChanged
{
    if (_database) {
        [self quitDatabase];
    }
    [self setupDatabase];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupDatabase
{
    if (_database) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
//    if ([PMXAuth sharedInstance].userId.length) {
//        _filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.sqlite", [PMXAuth sharedInstance].userId, CURRENT_DB_VERSION]];
//    }
//    else {
//        _filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"unauthorized-%@.sqlite", CURRENT_DB_VERSION]];
//    }
    _database = [[YapDatabase alloc] initWithPath:_filePath];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yapDatabaseModified:) name:YapDatabaseModifiedNotification object:_database];
    _writeConnection = [_database newConnection];
    _enumerateConnection = [_database newConnection];
    _searchConnection = [_database newConnection];
    
    _readConnection = [_database newConnection];
    [_readConnection beginLongLivedReadTransaction];
    _searchQueue = [[YapDatabaseSearchQueue alloc] init];
    
    _tempDataStore = [NSMutableDictionary dictionary];
    
    _dataStoreWillUpdateBlocks = [NSMutableDictionary dictionary];
    _dataStoreDidUpdateBlocks = [NSMutableDictionary dictionary];
    _dataStoreDidRemoveBlocks = [NSMutableDictionary dictionary];
    
    self.databaseReady = YES;
}

- (void)quitDatabase
{
//    if (([_filePath containsString:@"unauthorized"] && ![PMXAuth sharedInstance].userId.length) || ([PMXAuth sharedInstance].userId && [_filePath containsString:[PMXAuth sharedInstance].userId])) {
//        return;
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _database = nil;
    _writeConnection = nil;
    _readConnection = nil;
    _searchConnection = nil;
    _enumerateConnection = nil;
    _searchQueue = nil;
    
    _tempDataStore = nil;
    
    _dataStoreWillUpdateBlocks = nil;
    _dataStoreDidUpdateBlocks = nil;
    _dataStoreDidRemoveBlocks = nil;
    
    self.databaseReady = NO;
}

- (void)beginLongLivedReadTransaction
{
    [_readConnection beginLongLivedReadTransaction];
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
        [_writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            id oldObject = [transaction objectForKey:key inCollection:collection];
            
            PMXDataStoreWillUpdateBlock willUpdateBlock = [_dataStoreWillUpdateBlocks objectForKey:collection];
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
            PMXDataStoreDidUpdateBlock didUpdateBlock = [_dataStoreDidUpdateBlocks objectForKey:collection];
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
        [_writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            if ([transaction objectForKey:key inCollection:collection]) {
                if ([collection isEqualToString:@"message"]) {
                    NSDictionary *transactionExtendedInfo = @{@"deleteMessage": key};
                    transaction.yapDatabaseModifiedNotificationCustomObject = transactionExtendedInfo;
                }
                [transaction removeObjectForKey:key inCollection:collection];
            }
        } completionBlock:^{
            PMXDataStoreDidRemoveBlock didRemoveBlock = [_dataStoreDidRemoveBlocks objectForKey:collection];
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
	[_enumerateConnection asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
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

- (void)registerExtension:(id)extension withName:(NSString*)name completionBlock:(void(^)(BOOL ready))completionBlock
{
    [_database asyncRegisterExtension:extension withName:name completionBlock:completionBlock];
}

- (void)unregisterExtensionWithName:(NSString*)name
{
    [_database asyncUnregisterExtensionWithName:name completionBlock:nil];
}

# pragma mark - View mapping helpers

- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(PMXDataStoreViewMappings*)mappings
{
    return [[_readConnection ext:mappings.viewName] hasChangesForNotifications:notifications];
}

- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection inNotifications:(NSArray *)notifications
{
    return [_readConnection hasChangeForKey:key inCollection:collection inNotifications:notifications];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(PMXDataStoreViewMappings*)mappings
{
    __block id result;
    [_readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        result = [[transaction ext:mappings.viewName] objectAtIndexPath:indexPath withMappings:(YapDatabaseViewMappings*)mappings.mappings];
    }];
    return result;
}

- (void)updateArrayDataMappings:(PMXDataStoreViewMappings*)mappings
{
    [_readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [mappings.mappings updateWithTransaction:transaction];
    }];
}

- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(PMXDataStoreViewMappings*)mappings
{
    [[_readConnection ext:mappings.viewName] getSectionChanges:sectionChanges rowChanges:rowChanges forNotifications:notifications withMappings:mappings.mappings];
}

- (void)search:(NSString*)query viewMappings:(PMXDataStoreViewMappings*)viewMappings
{
    [_searchQueue enqueueQuery:query];
    [_searchConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [[transaction ext:viewMappings.viewName] performSearchWithQueue:_searchQueue];
    }];
}

@end
