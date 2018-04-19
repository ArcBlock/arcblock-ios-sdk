//
//  PMXDataStore+ViewMappings.h
//  Pods
//
//  Created by Jonathan Lu on 19/4/2018.
//

#import "PMXDataStore.h"
#import "PMXViewMappings.h"

@interface PMXDataStore (ViewMappings)

// For view mappings update
- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(PMXViewMappings*)mappings;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(PMXViewMappings*)mappings;
- (void)updateArrayDataMappings:(PMXViewMappings*)mappings;
- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(PMXViewMappings*)mappings;

// For Search
- (void)search:(NSString*)query viewMappings:(PMXViewMappings*)viewMappings;

@end
