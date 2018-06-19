// ABSDKDataStore.h
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

#import <Foundation/Foundation.h>

/**
 *  This notification is posted when any object in the data store is changed. NSNotification with this name will provide 1) `object` that is the ABSDKDataStore posting the notification, and 2) `userInfo` that contains information about the changes
 **/
extern NSString *const ABSDKDataStoreModifiedNotification;

/**
 *  The block to modify value before written to the store
 *  @param  collection  The collection in which the key-value pair will be stored
 *  @param  key         The key of the key-value pair
 *  @param  object      The value of the key-value pair
 *  @return The final value to be written to the store
 **/
typedef NSDictionary* (^ABSDKDataStoreWillUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);

/**
 *  The block to perform additional actions after key-value pair is written to the store
 *  @param  collection  The collection in which the key-value pair is stored
 *  @param  key         The key of the key-value pair
 *  @param  object      The value of the key-value pair
 **/
typedef void (^ABSDKDataStoreDidUpdateBlock)(NSString *collection, NSString *key, NSDictionary* object);

/**
 *  The block to perform additional actions after key-value pair is removed from the store
 *  @param  collection  The collection in which the key-value pair is stored
 *  @param  key         The key of the key-value pair
 **/
typedef void (^ABSDKDataStoreDidRemoveBlock)(NSString *collection, NSString *key);

/**
 *  A key-value data store that supports observation.
 *
 *  Key-value pairs can be stored, retrived, updated and removed in a specified collection, with a specific key. Any change to the data store will trigger an NSNotification, so that the users can know when one certain key-value pair or a set of them has been changed(change includes creation, update and removal).
 *
 **/
@interface ABSDKDataStore : NSObject

/**
 *  Indicates if the instance has finished initial setup
 **/
@property (nonatomic, readonly) BOOL dataStoreReady;

/**
 *  To get the shared ABSDKDataStore instance
 *  @return The singleton instance
 **/
+ (ABSDKDataStore *)sharedInstance;

/**
 *  Register collections. Key value pairs stored in registered collections will be persist on disk, while those in unregistered collections will be store in memory
 *  @param  collections An array of strings of collections to register
 **/
- (void)registerCollections:(NSArray *)collections;

/**
 *  Set the ABSDKDataStoreWillUpdateBlock for a specific collection
 *  @param  collection  The collection to set the callback
 *  @param  block       The block to set. It will be called before any key-value pairs written to the collection
 **/
- (void)setDataStoreWillUpdateBlockForCollection:(NSString*)collection block:(ABSDKDataStoreWillUpdateBlock)block;

/**
 *  Set the ABSDKDataStoreWillUpdateBlock for a specific collection
 *  @param  collection  The collection to set the callback
 *  @param  block       The block to set. It will be called after any key-value pairs written to the collection
 **/
- (void)setDataStoreDidUpdateBlockForCollection:(NSString*)collection block:(ABSDKDataStoreDidUpdateBlock)block;

/**
 *  Set the ABSDKDataStoreWillUpdateBlock for a specific collection
 *  @param  collection  The collection to set the callback
 *  @param  block       The block to set. It will be called before any key-value pairs removed from the collection
 **/
- (void)setDataStoreDidRemoveBlockForCollection:(NSString*)collection block:(ABSDKDataStoreDidRemoveBlock)block;

/**
 *  Setup the store with a custom database file name for the on disk store. This will be useful when we want to separate data in different context.
 *  @param  dbFileName  Optional, Name of database file. ABSDKDataStore will use "tmp" when nil is passed
 **/
- (void)setupDataStore:(NSString*)dbFileName;

/**
 *  Reset the store
 **/
- (void)quitDataStore;

/**
 *  read a key value pair from the store
 *  @param  key                 The key of the key-value pair
 *  @param  collection          The collection in which the key-value pair is stored
 *  @return The value of the key value pair
 **/
- (NSDictionary*)objectForKey:(NSString*)key inCollection:(NSString*)collection;

/**
 *  Write a key value pair to the store
 *  @param  object              The value of the key-value pair
 *  @param  key                 The key of the key-value pair
 *  @param  collection          The collection in which the key-value pair will be stored
 *  @param  completionBlock     The block called after the key value pair is written
 **/
- (void)setObject:(NSDictionary*)object forKey:(NSString*)key inCollection:(NSString *)collection completionBlock:(dispatch_block_t)completionBlock;

/**
 *  remove a key value pair from the store
 *  @param  key                 The key of the key-value pair
 *  @param  collection          The collection in which the key-value pair is stored
 *  @param  completionBlock     The block called after the key value pair is removed
 **/
- (void)removeObjectForKey:(NSString*)key inCollection:(NSString*)collection completionBlock:(dispatch_block_t)completionBlock;

/**
 *  Check if a key value pair has been changed
 *  @param  key                 The key of the key-value pair
 *  @param  collection          The collection in which the key-value pair is stored
 *  @param  notification        The notification user recieved when the data store has any changes
 *  @return YES if the key value pair has been changed, otherwise NO
 **/
- (BOOL)hasChangeForKey:(NSString*)key inCollection:(NSString *)collection notification:(NSNotification *)notification;

/**
 *  Get all the keys of the key value pairs store in a collection
 *  @param  collection  The collection of the key-value pair
 *  @return An array of keys
 **/
- (NSArray*)allKeysInCollection:(NSString*)collection;

/**
 *  Enumerate all the key value pairs in a collection
 *  @param  collection  The collection to enumerate
 *  @param  block       The block being used to process every key value pair in the collection
 **/
- (void)enumerateKeysAndObjectsInCollection:(NSString *)collection usingBlock:(void (^)(NSString *key, NSDictionary *object, BOOL *stop))block;

@end
