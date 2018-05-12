//
//  ABSDKDataStore+ABSDKArrayDataSource.h
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 11/5/2018.
//

#import "ABSDKDataStore.h"

@interface ABSDKDataStore (ABSDKArrayDataSource)

- (void)registerExtension:(id)extension withName:(NSString*)name completionBlock:(void(^)(BOOL ready))completionBlock;
- (void)unregisterExtensionWithName:(NSString*)name;

- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(id)mappings;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(id)mappings;
- (void)updateArrayDataMappings:(id)mappings;
- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(id)mappings;

// For Search
- (void)search:(NSString*)query mappings:(id)mappings;

@end
