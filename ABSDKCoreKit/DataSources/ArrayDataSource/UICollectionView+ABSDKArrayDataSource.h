// UICollectionView+ABSDKArrayDataSource.h
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

#import <UIKit/UIKit.h>
#import "ABSDKArrayDataSource.h"

/**
 *  A UICollectionView category that supports binding with ABSDKArrayDataSource.
 **/
@interface UICollectionView (ABSDKArrayDataSource)

/**
 *  Obverse the data change via an ABSDKArrayDataSource object
 *  @param  arrayDataSource     The arrayDataSource to observe
 *  @param  updatedBlock        The callback to perform more actions when data change
 **/
- (void)observeArrayDataSource:(ABSDKArrayDataSource*)arrayDataSource updatedBlock:(void (^)(void))updatedBlock;

/**
 *  Update the collection view itself with section and row changes. Changes could be insert, delete, or update.
 *  @param  sectionChanges  The array of section changes
 *  @param  rowChanges      The array of row changes
 *  @param  completion      The callback to perform more actions when collection view update ends
 **/
- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges completion:(void (^)(BOOL finished))completion;

@end
