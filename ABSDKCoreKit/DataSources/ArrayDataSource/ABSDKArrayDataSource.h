// ABSDKArrayDataSource.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  This notification is posted when an ABSDKArrayDataSource is changed. NSNotification with this name will provide 1) `object` that is the ABSDKArrayDataSource instance posting the notification, and 2) `userInfo` that contains the changes to the array
 **/
extern NSString *const ABSDKArrayDataSourceDidUpdateNotification;

/**
 *  The grouping block. Iterate all the key value pairs in the data store to select items and group them into different sections.
 *  @param  collection  The collection of the current iterated key value pair
 *  @param  key         The key of the current iterated key value pair
 *  @param  object      The value of the current iterated key value pair
 *  @return The name or identifier of the section that the current iterated key value pair should be grouped into. Default return nil, meaning that the the current iterated key value pair will not be selected by the calling ABSDKArrayDataSource instance.
 **/
typedef NSString* (^ABSDKArrayDataSourceGroupingBlock)(NSString *collection, NSString *key, NSDictionary *object);

/**
 *  The sorting block. Iterate all the items grouped in a section to sort them in a specific order.
 *  @param  group       The name or identifier of the current section
 *  @param  collection1 The collection of the first current iterated item
 *  @param  key1        The key of the first current iterated item
 *  @param  object1     The value of the first current iterated item
 *  @param  collection2 The collection of the second current iterated item
 *  @param  key2        The key of the second current iterated item
 *  @param  object2     The value of the second current iterated item
 *  @return The result of the comparison(ascending, descending or equal)
 **/
typedef NSComparisonResult (^ABSDKArrayDataSourceSortingBlock) (NSString *group, NSString *collection1, NSString *key1, NSDictionary *object1, NSString *collection2, NSString *key2, NSDictionary *object2);

/**
 *  Key value pairs in the data store can be composed to form an array of arrays in order to power a table view or a collection view. Each subarray is called a section. ABSDKArrayDataSource is a read only data source object that represents the array structure.
 *
 *  Read only means that you can only read the array structure and the items in it via the data source, but can't mutate via it. If you want to do mutation, you need to call methods on the ABSDKDataStore singleton.
 *
 *  The data source will send ABSDKArrayDataSourceDidUpdateNotification when the array structure or items in it is changed.
 **/
@interface ABSDKArrayDataSource : NSObject

/**
 *  The unique identifier of the array data source
 **/
@property (nonatomic, strong, readonly) NSString* identifier;

/**
 *  An array of section names or identifiers. Items represented by an ABSDKArrayDataSource are organized into sections. Each section will be rendered into a section in table view or collection view.
 **/
@property (nonatomic, readonly) NSArray *sections;

/**
 *  Indicates if the ABSDKArrayDataSource is still loading.
 **/
@property (nonatomic, readonly) BOOL isLoading;

/**
 *  Indicates if the array represented by an ABSDKArrayDataSource is empty.
 **/
@property (nonatomic, readonly) BOOL empty;

/**
 *  Indicates if the ABSDKArrayDataSource is only representing part of the sections. Useful for pagination.
 **/
@property (nonatomic, readonly) BOOL hasMore;

/**
 *  Maximum number of items the ABSDKArrayDataSource will represent in the sections. Useful for pagination. Default is -1, meaning that show all the items in the targeted array.
 **/
@property (nonatomic) NSInteger limit;

/**
 *  Initialize an ABSDKArrayDataSource
 *  @param  identifier      The unique identifier
 *  @param  sections        The array of section names or identifiers
 *  @param  groupingBlock   The grouping block
 *  @param  sortingBlock    The sorting block
 *  @return An instance of ABSDKArrayDataSource
 **/
- (id)initWithIdentifier:(NSString*)identifier sections:(NSArray*)sections groupingBlock:(ABSDKArrayDataSourceGroupingBlock)groupingBlock sortingBlock:(ABSDKArrayDataSourceSortingBlock)sortingBlock;

/**
 *  reload data source to the latest state of the data store
 **/
- (void)loadData;

/**
 *  Get all the items in all sections
 *  @return An array of items
 **/
- (NSArray*)allItems;

/**
 *  Get Number of sections
 *  @return Number of sections
 **/
- (NSInteger)numberOfSections;

/**
 *  Get Number of items in an section
 *  @param  section     Index of the section
 *  @return Number of items in the section
 **/
- (NSInteger)numberOfItemsForSection:(NSInteger)section;

/**
 *  Get item at an index path
 *  @param  indexPath     Index path(section index + row index) of the desired item
 *  @return The value of the item
 **/
- (NSDictionary*)objectAtIndexPath:(NSIndexPath*)indexPath;

@end
