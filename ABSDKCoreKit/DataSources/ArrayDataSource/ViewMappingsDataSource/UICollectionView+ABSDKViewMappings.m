//
//  UICollectionView+ABSDKViewMappings.m
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import "UICollectionView+ABSDKViewMappings.h"
#import "YapDatabaseView.h"

@implementation UICollectionView (ABSDKViewMappings)

- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges completion:(void (^)(BOOL finished))completion
{
    __weak typeof(self) wself = self;
    [self performBatchUpdates:^{
        for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
        {
            switch (sectionChange.type)
            {
                case YapDatabaseViewChangeDelete :
                {
                    [wself deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
                    break;
                }
                case YapDatabaseViewChangeInsert :
                {
                    [wself insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]];
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
            [wself deleteItemsAtIndexPaths:deleteIndexes];
        }
        if (insertIndexes.count) {
            [wself insertItemsAtIndexPaths:insertIndexes];
        }
        if (reloadIndexes.count) {
            [wself reloadItemsAtIndexPaths:reloadIndexes];
        }
    } completion:^(BOOL finished) {

    }];
}

@end
