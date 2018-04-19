//
//  ABSDKDataStore+ViewMappings.h
//  Pods
//
//  Created by Jonathan Lu on 19/4/2018.
//

#import "ABSDKDataStore.h"
#import "ABSDKViewMappings.h"

@interface ABSDKDataStore (ViewMappings)

// For view mappings update
- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(ABSDKViewMappings*)mappings;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(ABSDKViewMappings*)mappings;
- (void)updateArrayDataMappings:(ABSDKViewMappings*)mappings;
- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(ABSDKViewMappings*)mappings;

// For Search
- (void)search:(NSString*)query viewMappings:(ABSDKViewMappings*)viewMappings;

@end
