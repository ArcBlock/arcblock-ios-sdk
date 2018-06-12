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

extern NSString *const ABSDKArrayDataSourceDidUpdateNotification;

typedef NSString* (^ABSDKArrayDataSourceGroupingBlock)(NSString *collection, NSString *key, NSDictionary *object);
typedef NSComparisonResult (^ABSDKArrayDataSourceSortingBlock) (NSString *group, NSString *collection1, NSString *key1, NSDictionary *object1, NSString *collection2, NSString *key2, NSDictionary *object2);
typedef BOOL (^ABSDKArrayDataSourceFilteringBlock)(NSString *group, NSString *collection, NSString *key, NSDictionary *object);
typedef void (^ABSDKArrayDataSourceSearchBlock)(NSMutableDictionary*dict, NSString *collection, NSString *key, NSDictionary *object);

@interface ABSDKArrayDataSource : NSObject

@property (nonatomic, strong, readonly) NSString* identifier;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL empty;

@property (nonatomic) NSInteger limit;

- (id)initWithIdentifier:(NSString*)identifier sections:(NSArray*)sections grouping:(ABSDKArrayDataSourceGroupingBlock)grouping sorting:(ABSDKArrayDataSourceSortingBlock)sorting;
- (void)loadData;
- (NSArray*)allItems;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsForSection:(NSInteger)section;
- (NSDictionary*)objectAtIndexPath:(NSIndexPath*)indexPath;

@end
