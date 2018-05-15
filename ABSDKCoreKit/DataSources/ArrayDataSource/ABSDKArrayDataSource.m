//
//  ABSDKArrayDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 17/11/2015.
//
//

#import "ABSDKArrayDataSource.h"
#import "ABSDKArrayDataSource+Private.h"
#import <YapDatabase/YapDatabaseAutoView.h>
#import <YapDatabase/YapDatabaseViewMappings.h>
#import "ABSDKDataStore+Private.h"
#import "FBKVOController.h"

NSString *const ABSDKArrayDataSourceDidUpdateNotification = @"ABSDKArrayDataSourceDidUpdateNotification";

@interface ABSDKArrayDataSource ()

@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) YapDatabaseViewMappings *viewMappings;
@property (nonatomic, strong) YapDatabaseView *databaseView;

@end

@implementation ABSDKArrayDataSource

- (id)init
{
    self = [super init];
    if (self) {
        _limit = -1;
        _kvoController = [FBKVOController controllerWithObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreModified:) name:ABSDKDataStoreModifiedNotification object:[ABSDKDataStore sharedInstance]];
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)identifier sections:(NSArray*)sections grouping:(ABSDKArrayDataSourceGroupingBlock)grouping sorting:(ABSDKArrayDataSourceSortingBlock)sorting
{
    self = [self init];
    if (self) {
        _identifier = identifier;
        _sections = sections;

        YapDatabaseViewGrouping *databaseViewGrouping = [YapDatabaseViewGrouping withObjectBlock:^NSString * _Nullable(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull collection, NSString * _Nonnull key, id  _Nonnull object) {
            return grouping(collection, key, object);
        }];
        YapDatabaseViewSorting *databaseViewSorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction * _Nonnull transaction, NSString * _Nonnull group, NSString * _Nonnull collection1, NSString * _Nonnull key1, id  _Nonnull object1, NSString * _Nonnull collection2, NSString * _Nonnull key2, id  _Nonnull object2) {
            return sorting(group, collection1, key1, object1, collection2, key2, object2);
        }];

        self.databaseView = [[YapDatabaseAutoView alloc] initWithGrouping:databaseViewGrouping sorting:databaseViewSorting];
    }
    return self;
}

- (void)dealloc
{
    [self resetView];
}

- (void)setDatabaseView:(YapDatabaseView *)databaseView
{
    _databaseView = databaseView;
    __weak typeof(self) wself = self;
    [_kvoController observe:[ABSDKDataStore sharedInstance] keyPath:@"dataStoreReady" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        if ([ABSDKDataStore sharedInstance].dataStoreReady) {
            [wself setupView];
        }
        else {
            [wself resetView];
        }
    }];

    if ([ABSDKDataStore sharedInstance].dataStoreReady) {
        [self setupView];
    }
}

- (void)resetView
{
    [[ABSDKDataStore sharedInstance].database unregisterExtensionWithName:_identifier];
    self.viewMappings = nil;
    [self loadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView
{
    __weak typeof(self) wself = self;
    [[ABSDKDataStore sharedInstance].database asyncRegisterExtension:_databaseView withName:_identifier completionBlock:^(BOOL ready) {
        if (ready) {
            wself.viewMappings = [[YapDatabaseViewMappings alloc] initWithGroups:wself.sections view:wself.identifier];
            [wself loadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKArrayDataSourceDidUpdateNotification object:self];
        }
    }];
}

- (void)loadData
{
    __weak typeof(self) wself = self;
    [[ABSDKDataStore sharedInstance].readConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        [wself.viewMappings updateWithTransaction:transaction];
    }];
}

- (void)dataStoreModified:(NSNotification *)notification
{
    if ([notification.userInfo[@"inMemory"] boolValue]) {
        return;
    }
    NSArray *notifications = notification.userInfo[@"notifications"];

    if (![[[ABSDKDataStore sharedInstance].readConnection ext:_viewMappings.view] hasChangesForNotifications:notifications]) {
        [self loadData];
        return;
    }
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    [[[ABSDKDataStore sharedInstance].readConnection ext:_viewMappings.view] getSectionChanges:&sectionChanges rowChanges:&rowChanges forNotifications:notifications withMappings:_viewMappings];
    if ([sectionChanges count] == 0 && [rowChanges count] == 0)
    {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ABSDKArrayDataSourceDidUpdateNotification object:self userInfo:@{@"sectionChanges": sectionChanges, @"rowChanges": rowChanges, @"notifications": notifications}];
}

- (NSInteger)numberOfSections
{
    return [_viewMappings numberOfSections];
}

- (NSInteger)numberOfItemsForSection:(NSInteger)section
{
    return [_viewMappings numberOfItemsInSection:section];
}

- (NSDictionary*)objectAtIndexPath:(NSIndexPath*)indexPath
{
    __block id result;
    __weak typeof(self) wself = self;
    [[ABSDKDataStore sharedInstance].readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        result = [[transaction ext:wself.viewMappings.view] objectAtIndexPath:indexPath withMappings:wself.viewMappings];
    }];
    return result;
}

- (BOOL)isEmpty{
    for (int i = 0; i < [self numberOfSections]; i++) {
        if ([self numberOfItemsForSection:i]) {
            return NO;
        }
    }
    return YES;
}

- (void)setLimit:(NSInteger)limit
{
    if (_sections.count > 1) {
        return;
    }
    _limit = limit;
    if (_limit >= 0) {
        YapDatabaseViewRangeOptions *options = [YapDatabaseViewRangeOptions flexibleRangeWithLength:limit offset:0 from:YapDatabaseViewBeginning];
        options.maxLength = limit;
        options.growOptions = YapDatabaseViewGrowOnBothSides;
        [_viewMappings setRangeOptions:options forGroup:_sections[0]];
    }
    else {
        [_viewMappings setRangeOptions:nil forGroup:_sections[0]];
    }
}

- (NSArray*)allItems
{
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < self.numberOfSections; i++) {
        for (int j = 0; j < [self numberOfItemsForSection:i]; j++) {
            if ([self objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]) {
                [items addObject:[self objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]];
            }
        }
    }
    return items;
}

@end

