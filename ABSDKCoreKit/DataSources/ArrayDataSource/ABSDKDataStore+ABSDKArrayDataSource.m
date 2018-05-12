//
//  ABSDKDataStore+ABSDKArrayDataSource.m
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 11/5/2018.
//

#import "ABSDKDataStore+ABSDKArrayDataSource.h"
#import "ABSDKDataStore+Private.h"
#import <YapDatabase/YapDatabaseView.h>
#import <YapDatabase/YapDatabaseSearchResultsView.h>
#import <YapDatabase/YapDatabaseViewMappings.h>

@implementation ABSDKDataStore (ABSDKArrayDataSource)

- (void)registerExtension:(id)extension withName:(NSString*)name completionBlock:(void(^)(BOOL ready))completionBlock
{
    [self.database asyncRegisterExtension:extension withName:name completionBlock:completionBlock];
}

- (void)unregisterExtensionWithName:(NSString*)name
{
    [self.database asyncUnregisterExtensionWithName:name completionBlock:nil];
}

- (BOOL)hasChangesForNotifications:(NSArray *)notifications mappings:(id)mappings
{
    if (![mappings isKindOfClass:[YapDatabaseViewMappings class]]) {
        return NO;
    }
    return [[self.readConnection ext:[(YapDatabaseViewMappings*)mappings view]] hasChangesForNotifications:notifications];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath withMappings:(id)mappings
{
    if (![mappings isKindOfClass:[YapDatabaseViewMappings class]]) {
        return nil;
    }
    __block id result;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        result = [[transaction ext:[(YapDatabaseViewMappings*)mappings view]] objectAtIndexPath:indexPath withMappings:mappings];
    }];
    return result;
}

- (void)updateArrayDataMappings:(id)mappings
{
    if (![mappings isKindOfClass:[YapDatabaseViewMappings class]]) {
        return;
    }
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [mappings updateWithTransaction:transaction];
    }];
}

- (void)sectionChanges:(NSArray**)sectionChanges rowChanges:(NSArray**)rowChanges forNotifications:(NSArray*)notifications withMappings:(id)mappings
{
    if (![mappings isKindOfClass:[YapDatabaseViewMappings class]]) {
        return;
    }
    [[self.readConnection ext:[(YapDatabaseViewMappings*)mappings view]] getSectionChanges:sectionChanges rowChanges:rowChanges forNotifications:notifications withMappings:mappings];
}

- (void)search:(NSString*)query mappings:(id)mappings
{
    if (![mappings isKindOfClass:[YapDatabaseViewMappings class]]) {
        return;
    }
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [[transaction ext:[(YapDatabaseViewMappings*)mappings view]] performSearchFor:query];
    }];
}

@end
