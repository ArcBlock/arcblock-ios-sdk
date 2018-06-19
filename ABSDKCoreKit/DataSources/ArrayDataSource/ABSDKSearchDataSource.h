// ABSDKSearchDataSource.h
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

#import "ABSDKArrayDataSource.h"

/**
 *  When you add or update key value pairs in the data store the ABSDKArrayDataSourceSearchBlock is invoked. Your block can inspect the key value pair and determine if it contains any text columns that should be indexed. If not, the  block can simply return. Otherwise the block should extract any text values, and add them to the given dictionary.
 *
 *  After the block returns, the dictionary parameter will be inspected, and any set values will be automatically indexed.
 *
 *  @param dict         The dictonary to be inspected later for indexing.
 *  @param  collection  The collection of the current iterated key value pair
 *  @param  key         The key of the current iterated key value pair
 *  @param  object      The value of the current iterated key value pair
 **/
typedef void (^ABSDKArrayDataSourceSearchBlock)(NSMutableDictionary*dict, NSString *collection, NSString *key, NSDictionary *object);

/**
 *  An ABSDKArrayDataSource subclass that supports full text search.
 **/
@interface ABSDKSearchDataSource : ABSDKArrayDataSource

/**
 *  Initialize an ABSDKSearchDataSource based on a parentDataSource
 *  @param  identifier          The unique identifier
 *  @param  parentDataSource    The parent array data source to apply filter to
 *  @param  columnNames        The collumns to index
 *  @param  searchBlock         The search block
 *  @return An instance of ABSDKSearchDataSource
 **/
- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource columnNames:(NSArray*)columnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock;

/**
 *  Initialize an ABSDKSearchDataSource without a parentDataSource
 *  @param  identifier          The unique identifier
 *  @param  columnNames        The collumns to index
 *  @param  searchBlock         The search block
 *  @param  sections        The array of section names or identifiers
 *  @param  groupingBlock   The grouping block
 *  @param  sortingBlock    The sorting block
 *  @return An instance of ABSDKSearchDataSource
 **/
- (id)initWithIdentifier:(NSString*)identifier columnNames:(NSArray*)columnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock sections:(NSArray*)sections groupingBlock:(ABSDKArrayDataSourceGroupingBlock)groupingBlock sortingBlock:(ABSDKArrayDataSourceSortingBlock)sortingBlock;

/**
 *  Apply search
 *  @param  searchString    The search string
 **/
- (void)search:(NSString*)searchString;

@end
