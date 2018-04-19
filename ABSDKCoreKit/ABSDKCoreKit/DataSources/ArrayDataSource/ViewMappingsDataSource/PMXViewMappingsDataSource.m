//
//  PMXViewMappingsDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 17/11/2015.
//
//

#import "PMXViewMappingsDataSource.h"
#import "PMXDataStore+ViewMappings.h"

@implementation PMXViewMappingsDataSource

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreModified:) name:PMXDataStoreModifiedNotification object:nil];
    }
    return self;
}

- (id)initWithName:(NSString*)name sections:(NSArray*)sections grouping:(PMXViewGroupingBlock)grouping sorting:(PMXViewSortingBlock)sorting
{
    self = [self init];
    if (self) {
        _name = name;
        self.sections = sections;
        _mappings = [[PMXViewMappings alloc] initWithViewName:name sections:sections grouping:grouping sorting:sorting];
        self.isRefreshing = YES;
        self.isLoading = YES;
        [self setup];
    }
    return self;
}

- (void)setup
{
    __weak typeof(self) wself = self;
    [_mappings setup:^(BOOL ready) {
        if (ready) {
            [wself loadData];
            wself.ready = YES;
        }
    }];
}

- (void)dealloc
{
    NSLog(@"deallocate %@", self.name);
    [[PMXDataStore sharedInstance] unregisterExtensionWithName:self.name];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataStoreModified:(NSNotification *)notification
{
    NSArray *notifications = notification.userInfo[@"notifications"];
    
    if (![[PMXDataStore sharedInstance] hasChangesForNotifications:notifications mappings:self.mappings]) {
        [self loadData];
        return;
    }

    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    [[PMXDataStore sharedInstance] sectionChanges:&sectionChanges rowChanges:&rowChanges forNotifications:notifications withMappings:_mappings];
    if ([sectionChanges count] == 0 && [rowChanges count] == 0)
    {
        [self loadData];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PMXArrayDataSourceDidUpdateNotification object:self userInfo:@{@"sectionChanges": sectionChanges, @"rowChanges": rowChanges, @"notifications": notifications}];
}

- (void)setLength:(NSInteger)length forSection:(NSString*)section
{
    [super setLength:length];
    [self.mappings setFlexibleRangeOptions:self.length offset:0 from:PMXViewBeginning maxLength:self.length growOption:PMXViewGrowOnBothSides forGroup:section];
}

- (void)setReverseForSection:(NSString*)section
{
    [self.mappings setIsReverse:YES forGroup:section];
}

- (void)loadData
{
    [[PMXDataStore sharedInstance] updateArrayDataMappings:self.mappings];
}

- (NSInteger) numberOfSections
{
    return _mappings.sections.count;
}

- (NSInteger) numberOfItemsForSection:(NSInteger)section
{
    return [_mappings numberOfItemsInSection:section];
}

- (id) getItemAtIndextPath:(NSIndexPath*)indexPath
{
    return [[PMXDataStore sharedInstance] objectAtIndexPath:indexPath withMappings:_mappings];
}

- (NSArray*)allItems
{
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < self.numberOfSections; i++) {
        for (int j = 0; j < [self numberOfItemsForSection:i]; j++) {
            if ([self getItemAtIndextPath:[NSIndexPath indexPathForRow:j inSection:i]]) {
                [items addObject:[self getItemAtIndextPath:[NSIndexPath indexPathForRow:j inSection:i]]];
            }
        }
    }
    return items;
}

- (BOOL)isEmpty{
    for (int i = 0; i < [self numberOfSections]; i++) {
        if ([self numberOfItemsForSection:i]) {
            return NO;
        }
    }
    return YES;
}

@end

