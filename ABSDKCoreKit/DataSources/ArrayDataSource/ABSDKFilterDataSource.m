//
//  ABSDKFilteringDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 7/7/2016.
//
//

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
