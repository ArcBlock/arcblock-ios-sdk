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
