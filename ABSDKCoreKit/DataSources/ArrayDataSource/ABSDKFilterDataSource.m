// ABSDKFilterDataSource.m
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

#import "ABSDKFilterDataSource.h"
#import "ABSDKArrayDataSource+Private.h"
#import <YapDatabase/YapDatabaseViewMappings.h>
#import <YapDatabase/YapDatabaseFilteredView.h>

@interface ABSDKFilterDataSource ()

@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) YapDatabaseViewMappings *viewMappings;
@property (nonatomic, assign) BOOL ready;

@end

@implementation ABSDKFilterDataSource
@synthesize identifier = _identifier;
@synthesize sections = _sections;
@synthesize ready = _ready;

- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource filterBlock:(ABSDKArrayDataSourceFilteringBlock)block
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _sections = parentDataSource.sections;

        YapDatabaseViewFiltering *filtering = [YapDatabaseViewFiltering withObjectBlock:^BOOL(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull group, NSString * _Nonnull collection, NSString * _Nonnull key, id  _Nonnull object) {
            return block(group, collection, key, object);
        }];

        YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
        options.isPersistent = NO;
        self.databaseView = [[YapDatabaseFilteredView alloc] initWithParentViewName:parentDataSource.identifier filtering:filtering versionTag:0 options:options];
    }
    return self;
}

@end
