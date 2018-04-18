//
//  PMXMeteorCollectionDataStore.h
//  Sprite
//
//  Created by Jonathan Lu on 5/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//
#ifndef CURRENT_DB_VERSION
#define CURRENT_DB_VERSION @"v1.0.21"
#endif

#import <YapDatabase/YapDatabase.h>
#import "PMXDataStoreViewMappings.h"

extern NSString *const PMXDataStoreModifiedNotification;
extern NSString *const PMXDataStoreCustomKey;

typedef NSDictionary* (^PMXDataStoreWillUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);
typedef void (^PMXDataStoreDidUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);
typedef void (^PMXDataStoreDidRemoveBlock)(NSString *collection, NSString *key);

@interface PMXDataStore : NSObject

+ (PMXDataStore *)sharedInstance;
@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic) BOOL databaseReady;
@property (nonatomic) NSMutableArray *collectionsInDatabase;
@property (nonatomic) NSMutableArray *collectionsInMemory;
@property (nonatomic) NSMutableDictionary *dataStoreWillUpdateBlocks; // actions to perform before updating data store
@property (nonatomic) NSMutableDictionary *dataStoreDidUpdateBlocks; // perform related updates on relational objects in other collection
@property (nonatomic) NSMutableDictionary *dataStoreDidRemoveBlocks;

- (void)beginLongLivedReadTransaction;

- (void)registerExtension:(id)extension withName:(NSString*)name completionBlock:(void(^)(BOOL ready))completionBlock;
- (void)unregisterExtensionWithName:(NSString*)name;

- (NSArray*)allKeysInCollection:(NSString*)collection;
- (void)setObject:(id)object forKey:(NSString*)key inCollection:(NSString *)collection;
- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection;
- (id)objectForKey:(NSString*)key inCollection:(NSString*)collection;
- (void)enumerateKeysAndObjectsInCollection:(NSString *)collection usingBlock:(void (^)(NSString *key, id object, BOOL *stop))block;

// For view mappings update
- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(PMXDataStoreViewMappings*)mappings;
- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection inNotifications:(NSArray *)notifications;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(PMXDataStoreViewMappings*)mappings;
- (void)updateArrayDataMappings:(PMXDataStoreViewMappings*)mappings;
- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(PMXDataStoreViewMappings*)mappings;

// For Search
- (void)search:(NSString*)query viewMappings:(PMXDataStoreViewMappings*)viewMappings;

@end
