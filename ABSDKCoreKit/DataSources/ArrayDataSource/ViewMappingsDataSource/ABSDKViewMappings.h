//
//  ABSDKArrayDataMappings.h
//  Pods
//
//  Created by Jonathan Lu on 29/12/2015.
//
//

#import <Foundation/Foundation.h>
#import "UITableView+ABSDKViewMappings.h"
#import "UICollectionView+ABSDKViewMappings.h"

struct ABSDKViewRangePosition {
    NSUInteger offsetFromBeginning;
    NSUInteger offsetFromEnd;
    NSUInteger length;
    
};
typedef struct ABSDKViewRangePosition ABSDKViewRangePosition;

typedef NS_ENUM(NSInteger, ABSDKViewPin) {
    ABSDKViewBeginning = 0,
    ABSDKViewEnd       = 1,
};

typedef NS_OPTIONS(NSUInteger, ABSDKViewGrowOptions) {
    ABSDKViewGrowPinSide    = 1 << 0,
    ABSDKViewGrowNonPinSide = 1 << 1,
    ABSDKViewGrowInRangeOnly = 0,
    ABSDKViewGrowOnBothSides = (ABSDKViewGrowPinSide | ABSDKViewGrowNonPinSide)
};

typedef NSString* (^ABSDKViewGroupingBlock)(id transaction, NSString *collection, NSString *key, id object);
typedef NSComparisonResult (^ABSDKViewSortingBlock) (id transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2);
typedef BOOL (^ABSDKDataStoreFilteringBlock)(id transaction, NSString *group, NSString *collection, NSString *key, id object);
typedef void (^ABSDKDataStoreFullTextSearchBlock)(NSMutableDictionary *dict, NSString *collection, NSString *key, id object);

@interface ABSDKViewMappings : NSObject

// basics
- (id)initWithViewName:(NSString*)viewName sections:(NSArray*)sections grouping:(ABSDKViewGroupingBlock)groupingBlock sorting:(ABSDKViewSortingBlock)sortingBlock;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id)mappings;
- (void)setup:(void(^)(BOOL ready))completionBlock;
@property (nonatomic, strong) NSString *viewName;
@property (nonatomic, strong) NSArray *sections;

// ranges
- (void)setIsReverse:(BOOL)isReverse forGroup:(NSString*)group;
- (void)setFlexibleRangeOptions:(NSUInteger)length offset:(NSUInteger)offset from:(ABSDKViewPin)viewPin maxLength:(NSUInteger)maxLength growOption:(ABSDKViewGrowOptions)growOptions forGroup:(NSString *)group;
- (ABSDKViewRangePosition)rangePositionForGroup:(NSString*)group;

@property (nonatomic, strong) NSString *parentViewName;

// search
@property (nonatomic, strong) NSArray *collumnNames;
@property (nonatomic, strong) NSString *searchName;
- (id)initWithCollumnNames:(NSArray*)collumnNames searchBlock:(ABSDKDataStoreFullTextSearchBlock)block parentViewName:(NSString*)parentViewName viewName:(NSString*)viewName sections:(NSArray*)sections;

// filter
- (id)initWithFilterBlock:(ABSDKDataStoreFilteringBlock)block parentViewName:(NSString*)parentViewName viewName:(NSString*)viewName sections:(NSArray*)sections;

@end
