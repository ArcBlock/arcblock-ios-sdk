//
//  UITableView+ABSDKArrayDataSource.m
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import "UITableView+ABSDKArrayDataSource.h"
#import "ABSDKArrayDataSource+Private.h"

@implementation UITableView (ABSDKArrayDataSource)

- (void)observeArrayDataSource:(ABSDKArrayDataSource*)arrayDataSource updatedBlock:(void (^)(void))updatedBlock
{
    [[NSNotificationCenter defaultCenter] addObserverForName:ABSDKArrayDataSourceDidUpdateNotification object:arrayDataSource queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        if (notification.userInfo) {
            [self updateWithSectionChanges:notification.userInfo[@"sectionChanges"] rowChanges:notification.userInfo[@"rowChanges"]];
        }
        else {
            [self reloadData];
        }
        if (updatedBlock) {
            updatedBlock();
        }
    }];
}

- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges
{
    [self beginUpdates];

    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                    withRowAnimation:UITableViewRowAnimationTop];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                    withRowAnimation:UITableViewRowAnimationTop];
                break;
            }
            default:
                break;
        }
    }

    NSMutableArray *insertIndexes = [NSMutableArray array];
    NSMutableArray *deleteIndexes = [NSMutableArray array];
    NSMutableArray *reloadIndexes = [NSMutableArray array];
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [deleteIndexes addObject:rowChange.indexPath];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [insertIndexes addObject:rowChange.newIndexPath];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [deleteIndexes addObject:rowChange.indexPath];
                [insertIndexes addObject:rowChange.newIndexPath];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [reloadIndexes addObject:rowChange.indexPath];
                break;
            }
        }
    }

    if (deleteIndexes.count) {
        [self deleteRowsAtIndexPaths:deleteIndexes withRowAnimation:UITableViewRowAnimationTop];
    }
    if (insertIndexes.count) {
        [self insertRowsAtIndexPaths:insertIndexes withRowAnimation:UITableViewRowAnimationTop];
    }
    if (reloadIndexes.count) {
        [self reloadRowsAtIndexPaths:reloadIndexes withRowAnimation:UITableViewRowAnimationNone];
    }

    [self endUpdates];
}

@end
