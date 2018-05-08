//
//  ABSDKDataStore+Private.h
//  Pods
//
//  Created by Jonathan Lu on 30/4/2018.
//

#import "ABSDKDataStore.h"
#import <YapDatabase/YapDatabase.h>

@interface ABSDKDataStore (Private)

@property (nonatomic, strong, readonly) YapDatabase *database;
@property (nonatomic, strong, readonly) YapDatabaseConnection *readConnection;

@end
