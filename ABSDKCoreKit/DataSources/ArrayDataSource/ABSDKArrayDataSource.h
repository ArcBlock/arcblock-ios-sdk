//
//  ABSDKArrayDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 17/11/2015.
//
//

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
