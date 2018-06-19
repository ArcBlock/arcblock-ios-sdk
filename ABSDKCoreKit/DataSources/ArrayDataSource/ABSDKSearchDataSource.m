// ABSDKSearchDataSource.m
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

- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource columnNames:(NSArray*)columnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _sections = parentDataSource.sections;
        _columnNames = columnNames;

        YapDatabaseFullTextSearchHandler *ftsHandler = [YapDatabaseFullTextSearchHandler withObjectBlock:searchBlock];
        _fts = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:_columnNames handler:ftsHandler];

        YapDatabaseSearchResultsViewOptions *options = [[YapDatabaseSearchResultsViewOptions alloc] init];
        options.isPersistent = NO;
        NSString *ftsName = [NSString stringWithFormat:@"%@-fts", _identifier];
        self.databaseView = [[YapDatabaseSearchResultsView alloc] initWithFullTextSearchName:ftsName parentViewName:parentDataSource.identifier versionTag:0 options:options];
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)identifier columnNames:(NSArray*)columnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock sections:(NSArray*)sections groupingBlock:(ABSDKArrayDataSourceGroupingBlock)groupingBlock sortingBlock:(ABSDKArrayDataSourceSortingBlock)sortingBlock
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
            return groupingBlock(collection, key, object);
        }];
        YapDatabaseViewSorting *databaseViewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull group, NSString * _Nonnull collection1, NSString * _Nonnull key1, id  _Nonnull object1, NSString * _Nonnull collection2, NSString * _Nonnull key2, id  _Nonnull object2) {
            return sortingBlock(group, collection1, key1, object1, collection2, key2, object2);
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
