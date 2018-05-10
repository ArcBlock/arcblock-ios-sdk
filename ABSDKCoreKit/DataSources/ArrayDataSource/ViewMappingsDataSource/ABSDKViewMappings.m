//
//  ABSDKArrayDataMappings.m
//  Pods
//
//  Created by Jonathan Lu on 29/12/2015.
//
//

#import "ABSDKViewMappings.h"
#import "ABSDKDataStore+ViewMappings.h"
#import "YapDatabase.h"
#import "YapDatabaseView.h"
#import "ABSDKDataStore.h"
#import "YapDatabaseFullTextSearch.h"
#import "YapDatabaseSearchResultsView.h"
#import "YapDatabaseFilteredView.h"

@interface ABSDKViewMappings ()

@property (nonatomic, strong) YapDatabaseView *databaseView;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;
@property (nonatomic, strong) YapDatabaseViewGrouping *grouping;
@property (nonatomic, strong) YapDatabaseViewSorting *sorting;
@property (nonatomic, strong) YapDatabaseViewFiltering *filtering;
@property (nonatomic, strong) YapDatabaseFullTextSearchHandler *ftsHandler;

@end

@implementation ABSDKViewMappings

# pragma mark - basics

- (id)initWithViewName:(NSString*)viewName sections:(NSArray*)sections grouping:(ABSDKViewGroupingBlock)groupingBlock sorting:(ABSDKViewSortingBlock)sortingBlock
{
    self = [super init];
    if (self) {
        _viewName = viewName;
        _sections = sections;
        _grouping = [YapDatabaseViewGrouping withObjectBlock:groupingBlock];
        _sorting = [YapDatabaseViewSorting withObjectBlock:sortingBlock];
    }
    return self;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return [_mappings numberOfItemsInSection:section];
}

- (id)mappings
{
    return _mappings;
}

- (void)setup:(void(^)(BOOL ready))completionBlock
{
    if (_ftsHandler) {
        YapDatabaseFullTextSearch *fts = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:_collumnNames handler:_ftsHandler versionTag:@"1"];
        YapDatabaseSearchResultsViewOptions *searchViewOptions = [[YapDatabaseSearchResultsViewOptions alloc] init];
        searchViewOptions.isPersistent = NO;
        _databaseView = [[YapDatabaseSearchResultsView alloc] initWithFullTextSearchName:_searchName parentViewName:_parentViewName versionTag:@"1" options:searchViewOptions];
        
        __weak typeof(self) wself = self;
        [[ABSDKDataStore sharedInstance] registerExtension:fts withName:_searchName completionBlock:^(BOOL ready) {
            if (ready) {
                [[ABSDKDataStore sharedInstance] registerExtension:wself.databaseView withName:wself.viewName completionBlock:^(BOOL ready) {
                    if (ready) {
                        wself.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:wself.sections view:wself.viewName];
                    }
                    completionBlock(ready);
                }];
            }
            else {
                completionBlock(ready);
            }
        }];
    }
    else if (_filtering) {
        _databaseView = [[YapDatabaseFilteredView alloc] initWithParentViewName:_parentViewName filtering:_filtering versionTag:@"1"];
        __weak typeof(self) wself = self;
        [[ABSDKDataStore sharedInstance] registerExtension:_databaseView withName:_viewName completionBlock:^(BOOL ready) {
            if (ready) {
                wself.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:wself.sections view:wself.viewName];
            }
            completionBlock(ready);
        }];
    }
    else {
//        _databaseView = [[YapDatabaseView alloc] initWithGrouping:_grouping sorting:_sorting versionTag:@"0"];
        __weak typeof(self) wself = self;
        [[ABSDKDataStore sharedInstance] registerExtension:_databaseView withName:_viewName completionBlock:^(BOOL ready) {
            if (ready) {
                wself.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:wself.sections view:wself.viewName];
            }
            completionBlock(ready);
        }];
    }
}

#pragma mark - search

- (id)initWithCollumnNames:(NSArray*)collumnNames searchBlock:(ABSDKDataStoreFullTextSearchBlock)block parentViewName:(NSString*)parentViewName viewName:(NSString*)viewName sections:(NSArray*)sections
{
    self = [super init];
    if (self) {
        _collumnNames = collumnNames;
        _parentViewName = parentViewName;
        _searchName = [NSString stringWithFormat:@"%@-fts", parentViewName];
        _viewName = viewName;
        _sections = sections;
        _ftsHandler = [YapDatabaseFullTextSearchHandler withObjectBlock:block];
    }
    return self;
}

#pragma mark - search

- (id)initWithFilterBlock:(ABSDKDataStoreFilteringBlock)block parentViewName:(NSString*)parentViewName viewName:(NSString*)viewName sections:(NSArray*)sections
{
    self = [super init];
    if (self) {
        _parentViewName = parentViewName;
        _viewName = viewName;
        _sections = sections;
        _filtering = [YapDatabaseViewFiltering withObjectBlock:block];
    }
    return self;
}

#pragma mark - range

- (void)setIsReverse:(BOOL)isReverse forGroup:(NSString*)group
{
    [_mappings setIsReversed:isReverse forGroup:group];
}

- (ABSDKViewRangePosition)rangePositionForGroup:(NSString*)group
{
    YapDatabaseViewRangePosition rangePosition = [_mappings rangePositionForGroup:group];
    return (ABSDKViewRangePosition){
        .offsetFromBeginning = rangePosition.offsetFromBeginning,
        .offsetFromEnd = rangePosition.offsetFromEnd,
        .length = rangePosition.length
    };
}

- (void)setFlexibleRangeOptions:(NSUInteger)length offset:(NSUInteger)offset from:(ABSDKViewPin)viewPin maxLength:(NSUInteger)maxLength growOption:(ABSDKViewGrowOptions)growOptions forGroup:(NSString *)group
{
    if (length > 0) {
        YapDatabaseViewRangeOptions *rangeOpts = [YapDatabaseViewRangeOptions flexibleRangeWithLength:length offset:offset from:(YapDatabaseViewPin)viewPin];
        rangeOpts.growOptions = (YapDatabaseViewGrowOptions)growOptions;
        rangeOpts.maxLength = maxLength;
        [_mappings setRangeOptions:rangeOpts forGroup:group];
    }
    else {
        [_mappings setRangeOptions:nil forGroup:group];
    }
    
}

@end
