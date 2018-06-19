// UIView+ABSDKObjectDataSource.h
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
#import "UIImageView+ABSDKObjectDataSource.h"
#import "UIButton+ABSDKObjectDataSource.h"
#import "ABSDKObjectDataSource.h"

/**
 *  A UIView category that supports binding with ABSDKObjectDataSource.
 **/
@interface UIView (ABSDKObjectDataSource)

/**
 *  Bind a key in the key value pair with a property of a view object
 *  @param  viewKey     The property name of the view
 *  @param  objectKey   The key in the key value pair
 **/
- (void)bind:(NSString*)viewKey objectKey:(NSString*)objectKey;

/**
 *  Obverse the data change via an ABSDKObjectDataSource object
 *  @param  objectDataSource    The objectDataSource to observe
 *  @param  updatedBlock        The callback to perform more actions when data change
 **/
- (void)observeObjectDataSource:(ABSDKObjectDataSource*)objectDataSource updatedBlock:(void (^)(void))updatedBlock;

/**
 *  Update the view itself with a key value pair
 *  @param  object  The key value pair to update view with
 **/
- (void)updateWithObject:(NSDictionary*)object;

@end
