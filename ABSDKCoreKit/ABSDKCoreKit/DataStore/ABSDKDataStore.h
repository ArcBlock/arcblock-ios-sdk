//
//  ABSDKMeteorCollectionDataStore.h
//  Sprite
//
//  Created by Jonathan Lu on 5/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>

extern NSString *const ABSDKDataStoreModifiedNotification;

typedef NSDictionary* (^ABSDKDataStoreWillUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);
typedef void (^ABSDKDataStoreDidUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);
typedef void (^ABSDKDataStoreDidRemoveBlock)(NSString *collection, NSString *key);

@interface ABSDKDataStore : NSObject

+ (ABSDKDataStore *)sharedInstance;

@property (nonatomic, readonly) BOOL dataStoreReady;
@property (nonatomic, strong, readonly) YapDatabaseConnection *readConnection;
@property (nonatomic, strong, readonly) NSArray *registeredCollections;

@property (nonatomic) NSMutableDictionary *dataStoreWillUpdateBlocks; // actions to perform before updating data store
@property (nonatomic) NSMutableDictionary *dataStoreDidUpdateBlocks; // perform related updates on relational objects in other collection
@property (nonatomic) NSMutableDictionary *dataStoreDidRemoveBlocks;

// collections not registered will be store only in memory
- (void)registerCollections:(NSArray *)collections;

- (void)setupDataStore:(NSString*)dbFileName;
- (void)quitDataStore;

- (void)registerExtension:(id)extension withName:(NSString*)name completionBlock:(void(^)(BOOL ready))completionBlock;
- (void)unregisterExtensionWithName:(NSString*)name;

- (NSArray*)allKeysInCollection:(NSString*)collection;
- (void)setObject:(id)object forKey:(NSString*)key inCollection:(NSString *)collection completionBlock:(dispatch_block_t)completionBlock;
- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection;
- (id)objectForKey:(NSString*)key inCollection:(NSString*)collection;
- (void)enumerateKeysAndObjectsInCollection:(NSString *)collection usingBlock:(void (^)(NSString *key, id object, BOOL *stop))block;
- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection inNotifications:(NSArray *)notifications;

@end
