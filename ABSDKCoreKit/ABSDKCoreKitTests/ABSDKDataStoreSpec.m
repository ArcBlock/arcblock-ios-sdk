//
//  ABSDKDataStoreSpec.m
//  Pods
//
//  Created by Jonathan Lu on 27/4/2018.
//  Copyright 2018 ___ORGANIZATIONNAME___. All rights reserved.
//

#import "Specta.h"
#import "ABSDKDataStore.h"
#import "Expecta.h"

SpecBegin(ABSDKDataStore)

describe(@"ABSDKDataStore", ^{
    
    __block ABSDKDataStore *dataStore;
    __block NSString *collection = @"collection";
    __block NSString *collectionNotRegistered = @"collectionNotRegistered";
    __block NSString *key1 = @"key1";
    __block NSString *key2 = @"key2";
    __block NSString *key3 = @"key3";
    __block NSString *key4 = @"key4";
    __block NSString *object1 = @"object1";
    __block NSString *object2 = @"object2";
    __block NSString *object3 = @"object3";
    __block NSString *object4 = @"object4";
    
    beforeAll(^{
        dataStore = [ABSDKDataStore sharedInstance];
    });
    
    describe(@"data store state", ^{
        context(@"when it is setup", ^{
            beforeEach(^{
                [dataStore quitDataStore];
                [dataStore setupDataStore:nil];
            });
            
            it(@"it should be ready", ^{
                expect(dataStore.dataStoreReady).beTruthy();
            });
        });
        
        context(@"when it is quit", ^{
            beforeEach(^{
                [dataStore setupDataStore:nil];
                [dataStore quitDataStore];
            });
            
            it(@"it should not be ready", ^{
                expect(dataStore.dataStoreReady).beFalsy();
            });
        });
    });
    
    describe(@"collection registration", ^{
        beforeEach(^{
            [dataStore setupDataStore:nil];
            [dataStore registerCollections:@[collection]];
        });
        
        it(@"collection should be registered", ^{
            expect([dataStore isRegisteredCollections:collection]).beTruthy();
            expect([dataStore isRegisteredCollections:collectionNotRegistered]).beFalsy();
        });
    });
    
    describe(@"data persistence", ^{
        beforeEach(^{
            [dataStore registerCollections:@[collection]];
            [dataStore setObject:object1 forKey:key1 inCollection:collection completionBlock:nil];
            [dataStore setObject:object2 forKey:key2 inCollection:collection completionBlock:nil];
            [dataStore setObject:object3 forKey:key3 inCollection:collectionNotRegistered completionBlock:nil];
            [dataStore setObject:object4 forKey:key4 inCollection:collectionNotRegistered completionBlock:nil];
            [Expecta setAsynchronousTestTimeout:0.1];
        });
        
        it(@"get all keys in registered collections", ^{
            expect([NSSet setWithArray:[dataStore allKeysInCollection:collection]]).will.equal([NSSet setWithObjects:key1, key2, nil]);
        });
        
        it(@"get all keys in not registered collections", ^{
            expect([NSSet setWithArray:[dataStore allKeysInCollection:collectionNotRegistered]]).will.equal([NSSet setWithObjects:key3, key4, nil]);
        });
        
        it(@"get objects in registered collections", ^{
            expect([dataStore objectForKey:key1 inCollection:collection]).will.equal(object1);
            expect([dataStore objectForKey:key2 inCollection:collection]).will.equal(object2);
        });
        
        it(@"get objects in registered collections", ^{
            expect([dataStore objectForKey:key3 inCollection:collectionNotRegistered]).will.equal(object3);
            expect([dataStore objectForKey:key4 inCollection:collectionNotRegistered]).will.equal(object4);
        });
        
        it(@"update objects in registered collections", ^{
            expect(^(){
                [dataStore setObject:object2 forKey:key1 inCollection:collection completionBlock:nil];
                expect([dataStore objectForKey:key1 inCollection:collection]).will.equal(object2);
            }).to.notify(ABSDKDataStoreModifiedNotification);
        });
        
        it(@"update objects in not registered collections", ^{
            expect(^(){
                [dataStore setObject:object4 forKey:key3 inCollection:collectionNotRegistered completionBlock:nil];
                expect([dataStore objectForKey:key3 inCollection:collectionNotRegistered]).will.equal(object4);
            }).to.notify(ABSDKDataStoreModifiedNotification);
        });
        
        it(@"remove objects in registered collections", ^{
            expect(^(){
                [dataStore removeObjectForKey:key2 inCollection:collection completionBlock:nil];
                expect([dataStore objectForKey:key2 inCollection:collection]).will.beNil();
            }).to.notify(ABSDKDataStoreModifiedNotification);
        });
        
        it(@"remove objects in not registered collections", ^{
            expect(^(){
                [dataStore removeObjectForKey:key4 inCollection:collectionNotRegistered completionBlock:nil];
                expect([dataStore objectForKey:key4 inCollection:collectionNotRegistered]).will.beNil();
            }).to.notify(ABSDKDataStoreModifiedNotification);
        });
    });
    
    afterAll(^{
        dataStore = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbFilePath = [documentDirectory stringByAppendingPathComponent:@"tmp.sqlite"];
        [[NSFileManager defaultManager] removeItemAtPath:dbFilePath error:nil];
    });
});

SpecEnd
