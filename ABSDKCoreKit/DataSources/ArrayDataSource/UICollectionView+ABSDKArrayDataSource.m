// UICollectionView+ABSDKArrayDataSource.m
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

#import "UICollectionView+ABSDKArrayDataSource.h"
#import "ABSDKArrayDataSource+Private.h"

@implementation UICollectionView (ABSDKArrayDataSource)

- (void)observeArrayDataSource:(ABSDKArrayDataSource*)arrayDataSource updatedBlock:(void (^)(void))updatedBlock
{
    [[NSNotificationCenter defaultCenter] addObserverForName:ABSDKArrayDataSourceDidUpdateNotification object:arrayDataSource queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        if (notification.userInfo) {
            [self updateWithSectionChanges:notification.userInfo[@"sectionChanges"] rowChanges:notification.userInfo[@"rowChanges"] completion:nil];
        }
        else {
            [self reloadData];
        }
        if (updatedBlock) {
            updatedBlock();
        }
    }];
}

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
