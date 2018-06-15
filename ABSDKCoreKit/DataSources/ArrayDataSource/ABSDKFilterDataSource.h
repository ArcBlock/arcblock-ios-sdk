// ABSDKFilterDataSource.h
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
 *  The filtering block. Iterate all the items in the parent ABSDKArrayDataSource to apply filter.
 *  @param  group       The section of the current iterated item
 *  @param  collection  The collection of the current iterated item
 *  @param  key         The key of the current iterated item
 *  @param  object      The value of the current iterated item
 *  @return A boolean to indicate if the item should pass the filter.
 **/
typedef BOOL (^ABSDKArrayDataSourceFilteringBlock)(NSString *group, NSString *collection, NSString *key, NSDictionary *object);

/**
 *  An ABSDKArrayDataSource subclass that filters another ABSDKArrayDataSource to get a subset of it.
 **/
@interface ABSDKFilterDataSource : ABSDKArrayDataSource

/**
 *  Initialize an ABSDKFilterDataSource
 *  @param  identifier          The unique identifier
 *  @param  parentDataSource    The parent array data source to apply filter to
 *  @param  filterBlock         The filter block
 *  @return An instance of ABSDKFilterDataSource
 **/
- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource filterBlock:(ABSDKArrayDataSourceFilteringBlock)filterBlock;

@end
