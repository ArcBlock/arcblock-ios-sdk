// ABSDKObjectDataSource.h
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

/**
 *  This notification is posted when an ABSDKObjectDataSource is changed. NSNotification with this name will provide 1) `object` that is the ABSDKObjectDataSource instance posting the notification, and 2) `userInfo` that contains the changes to the object
 **/
extern NSString *const ABSDKObjectDataSourceDidUpdateNotification;

/**
 *  A read only data source that represents a key value pair in the data store.
 *
 *  Read only means that you can only read the key value pair via the data source, but can't mutate via it. If you want to do mutation, you need to call methods on the ABSDKDataStore singleton.
 *
 *  The data source will send ABSDKObjectDataSourceDidUpdateNotification when the corresponding key value pair is changed.
 **/
@interface ABSDKObjectDataSource : NSObject

/**
 *  The collection of the represented key value pair
 **/
@property (nonatomic, strong, readonly) NSString *collection;

/**
 *  The key of the represented key value pair
 **/
@property (nonatomic, strong, readonly) NSString *key;

/**
 *  Get an ABSDKObjectDataSource instance with specified collection and key
 *  @param  collection  The collection of the represented key value pair
 *  @param  key         The key of the represented key value pair
 *  @return An instance of ABSDKObjectDataSource that represents the key value pair
 **/
+ (ABSDKObjectDataSource*)objectDataSourceWithCollection:(NSString*)collection key:(NSString*)key;

/**
 *  Get the represented key value pair
 *  @return The represented key value pair
 **/
- (NSDictionary*)fetchObject;

@end
