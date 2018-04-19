//
//  ABSDKDataStore+ViewMappings.m
//  Pods
//
//  Created by Jonathan Lu on 19/4/2018.
//

#import "ABSDKDataStore+ViewMappings.h"
#import "YapDatabaseView.h"
#import "YapDatabaseSearchResultsView.h"

@implementation ABSDKDataStore (ViewMappings)

- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(ABSDKViewMappings*)mappings
{
    return [[self.readConnection ext:mappings.viewName] hasChangesForNotifications:notifications];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(ABSDKViewMappings*)mappings
{
    __block id result;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        result = [[transaction ext:mappings.viewName] objectAtIndexPath:indexPath withMappings:(YapDatabaseViewMappings*)mappings.mappings];
    }];
    return result;
}

- (void)updateArrayDataMappings:(ABSDKViewMappings*)mappings
{
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [mappings.mappings updateWithTransaction:transaction];
    }];
}

- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(ABSDKViewMappings*)mappings
{
    [[self.readConnection ext:mappings.viewName] getSectionChanges:sectionChanges rowChanges:rowChanges forNotifications:notifications withMappings:mappings.mappings];
}

- (void)search:(NSString*)query viewMappings:(ABSDKViewMappings*)viewMappings
{
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [[transaction ext:viewMappings.viewName] performSearchFor:query];
    }];
}

@end
