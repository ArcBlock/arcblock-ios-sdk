//
//  ABSDKMeteorCollectionDataStore.h
//  Sprite
//
//  Created by Jonathan Lu on 5/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ABSDKDataStoreModifiedNotification;

typedef NSDictionary* (^ABSDKDataStoreWillUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);
typedef void (^ABSDKDataStoreDidUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);
typedef void (^ABSDKDataStoreDidRemoveBlock)(NSString *collection, NSString *key);

@interface ABSDKDataStore : NSObject

+ (ABSDKDataStore *)sharedInstance;

@property (nonatomic, readonly) BOOL dataStoreReady;

// collections not registered will be store only in memory
- (void)registerCollections:(NSArray *)collections;

// set data store change hooks
- (void)setDataStoreWillUpdateBlockForCollection:(NSString*)collection block:(ABSDKDataStoreWillUpdateBlock)block;
- (void)setDataStoreDidUpdateBlockForCollection:(NSString*)collection block:(ABSDKDataStoreDidUpdateBlock)block;
- (void)setDataStoreDidRemoveBlockForCollection:(NSString*)collection block:(ABSDKDataStoreDidRemoveBlock)block;

- (void)setupDataStore:(NSString*)dbFileName;
- (void)quitDataStore;

- (NSDictionary*)objectForKey:(NSString*)key inCollection:(NSString*)collection;
- (void)setObject:(NSDictionary*)object forKey:(NSString*)key inCollection:(NSString *)collection completionBlock:(dispatch_block_t)completionBlock;
- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection completionBlock:(dispatch_block_t)completionBlock;
- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection notification:(NSNotification *)notification;

- (NSArray*)allKeysInCollection:(NSString*)collection;
- (void)enumerateKeysAndObjectsInCollection:(NSString *)collection usingBlock:(void (^)(NSString *key, NSDictionary *object, BOOL *stop))block;

@end
