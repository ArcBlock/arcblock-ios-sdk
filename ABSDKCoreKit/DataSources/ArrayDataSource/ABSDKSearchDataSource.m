//
//  ABSDKSearchViewMappingsDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 20/6/2016.
//
//

#import "ABSDKSearchDataSource.h"
#import "ABSDKArrayDataSource+Private.h"
#import "ABSDKDataStore+Private.h"
#import <YapDatabase/YapDatabaseAutoView.h>
#import <YapDatabase/YapDatabaseViewMappings.h>
#import <YapDatabase/YapDatabaseFullTextSearch.h>
#import <YapDatabase/YapDatabaseSearchResultsView.h>

@interface ABSDKSearchDataSource ()

@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) YapDatabaseViewMappings *viewMappings;
@property (nonatomic, strong) NSArray *columnNames;
@property (nonatomic, strong) YapDatabaseFullTextSearch *fts;

@end

@implementation ABSDKSearchDataSource
@synthesize identifier = _identifier;
@synthesize sections = _sections;

- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource collumnNames:(NSArray*)collumnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _sections = parentDataSource.sections;
        _columnNames = collumnNames;

        YapDatabaseFullTextSearchHandler *ftsHandler = [YapDatabaseFullTextSearchHandler withObjectBlock:searchBlock];
        _fts = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:_columnNames handler:ftsHandler];

        YapDatabaseSearchResultsViewOptions *options = [[YapDatabaseSearchResultsViewOptions alloc] init];
        options.isPersistent = NO;
        NSString *ftsName = [NSString stringWithFormat:@"%@-fts", _identifier];
        self.databaseView = [[YapDatabaseSearchResultsView alloc] initWithFullTextSearchName:ftsName parentViewName:parentDataSource.identifier versionTag:0 options:options];
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)identifier columnNames:(NSArray*)columnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock sections:(NSArray*)sections grouping:(ABSDKArrayDataSourceGroupingBlock)grouping sorting:(ABSDKArrayDataSourceSortingBlock)sorting
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _sections = sections;
        _columnNames = columnNames;

        YapDatabaseFullTextSearchHandler *ftsHandler = [YapDatabaseFullTextSearchHandler withObjectBlock:searchBlock];
        _fts = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:_columnNames handler:ftsHandler];

        YapDatabaseSearchResultsViewOptions *options = [[YapDatabaseSearchResultsViewOptions alloc] init];
        options.isPersistent = NO;
        YapDatabaseViewGrouping *databaseViewGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString * _Nullable(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull collection, NSString * _Nonnull key, id  _Nonnull object) {
            return grouping(collection, key, object);
        }];
        YapDatabaseViewSorting *databaseViewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull group, NSString * _Nonnull collection1, NSString * _Nonnull key1, id  _Nonnull object1, NSString * _Nonnull collection2, NSString * _Nonnull key2, id  _Nonnull object2) {
            return sorting(group, collection1, key1, object1, collection2, key2, object2);
        }];
        NSString *ftsName = [NSString stringWithFormat:@"%@-fts", _identifier];
        self.databaseView = [[YapDatabaseSearchResultsView alloc] initWithFullTextSearchName:ftsName grouping:databaseViewGrouping sorting:databaseViewSorting versionTag:0 options:options];
    }
    return self;
}

- (void)resetView
{
    [[ABSDKDataStore sharedInstance].database unregisterExtensionWithName:((YapDatabaseSearchResultsView*)self.databaseView).fullTextSearchName];
    [super resetView];
}

- (void)setupView
{

    [[ABSDKDataStore sharedInstance].database asyncRegisterExtension:_fts withName:((YapDatabaseSearchResultsView*)self.databaseView).fullTextSearchName completionBlock:nil];
    [super setupView];
}

- (void)search:(NSString*)searchString
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];

    NSArray *searchComponents = [searchString componentsSeparatedByCharactersInSet:whitespace];
    NSMutableString *query = [NSMutableString string];

    for (NSString *term in searchComponents)
    {
        if ([term length] > 0)
            [query appendString:@""];

        [query appendFormat:@"%@*", term];
    }

    __weak typeof(self) wself = self;
    [[ABSDKDataStore sharedInstance].readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [[transaction ext:wself.viewMappings.view] performSearchFor:query];
    }];
}

@end
