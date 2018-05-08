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

- (void)setupDataStore:(NSString*)dbFileName;
- (void)quitDataStore;

- (NSArray*)allKeysInCollection:(NSString*)collection;
- (id)objectForKey:(NSString*)key inCollection:(NSString*)collection;
- (void)setObject:(id)object forKey:(NSString*)key inCollection:(NSString *)collection completionBlock:(dispatch_block_t)completionBlock;
- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection completionBlock:(dispatch_block_t)completionBlock;
- (void)enumerateKeysAndObjectsInCollection:(NSString *)collection usingBlock:(void (^)(NSString *key, id object, BOOL *stop))block;
- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection notification:(NSNotification *)notification;

@end
