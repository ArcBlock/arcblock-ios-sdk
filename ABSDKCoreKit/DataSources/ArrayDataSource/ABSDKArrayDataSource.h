//
//  ABSDKArrayDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 17/11/2015.
//
//

#import <Foundation/Foundation.h>
#import "UITableView+ABSDKArrayDataSource.h"
#import "UICollectionView+ABSDKArrayDataSource.h"

extern NSString *const PMXArrayDataSourceDidUpdateNotification;

typedef NSString* (^ABSDKArrayDataSourceGroupingBlock)(NSString *collection, NSString *key, NSDictionary *object);
typedef NSComparisonResult (^ABSDKArrayDataSourceSortingBlock) (NSString *group, NSString *collection1, NSString *key1, NSDictionary *object1, NSString *collection2, NSString *key2, NSDictionary *object2);
typedef BOOL (^ABSDKArrayDataSourceFilteringBlock)(NSString *group, NSString *collection, NSString *key, NSDictionary *object);
typedef void (^ABSDKArrayDataSourceSearchBlock)(NSMutableDictionary*dict, NSString *collection, NSString *key, NSDictionary *object);

@interface ABSDKArrayDataSource : NSObject

@property (nonatomic, strong, readonly) NSString* identifier;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL empty;

@property (nonatomic) NSInteger limit;

- (id)initWithIdentifier:(NSString*)identifier sections:(NSArray*)sections grouping:(ABSDKArrayDataSourceGroupingBlock)grouping sorting:(ABSDKArrayDataSourceSortingBlock)sorting;
- (void)setupView:(id)databaseView;
- (void)loadData;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsForSection:(NSInteger)section;
- (NSDictionary*)objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)allItems;

@end
