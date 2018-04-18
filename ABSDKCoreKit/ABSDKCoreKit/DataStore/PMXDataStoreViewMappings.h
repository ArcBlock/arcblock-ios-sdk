//
//  PMXArrayDataMappings.h
//  Pods
//
//  Created by Jonathan Lu on 29/12/2015.
//
//

#import <UIKit/UIKit.h>

struct PMXDataStoreViewRangePosition {
    NSUInteger offsetFromBeginning;
    NSUInteger offsetFromEnd;
    NSUInteger length;
    
};
typedef struct PMXDataStoreViewRangePosition PMXDataStoreViewRangePosition;

typedef NS_ENUM(NSInteger, PMXDataStoreViewPin) {
    PMXDataStoreViewBeginning = 0,
    PMXDataStoreViewEnd       = 1,
};

typedef NS_OPTIONS(NSUInteger, PMXDataStoreViewGrowOptions) {
    PMXDataStoreViewGrowPinSide    = 1 << 0,
    PMXDataStoreViewGrowNonPinSide = 1 << 1,
    
    PMXDataStoreViewGrowInRangeOnly = 0,
    PMXDataStoreViewGrowOnBothSides = (PMXDataStoreViewGrowPinSide | PMXDataStoreViewGrowNonPinSide)
};

typedef NSString* (^PMXDataStoreViewGroupingBlock)(NSString *collection, NSString *key, id object);
typedef NSComparisonResult (^PMXDataStoreViewSortingBlock) (NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2);
typedef void (^PMXDataStoreFullTextSearchBlock)(NSMutableDictionary *dict, NSString *collection, NSString *key, id object);
typedef BOOL (^PMXDataStoreFilteringBlock)(NSString *group, NSString *collection, NSString *key, id object);

@interface PMXDataStoreViewMappings : NSObject

// basics
- (id)initWithViewName:(NSString*)viewName sections:(NSArray*)sections grouping:(PMXDataStoreViewGroupingBlock)groupingBlock sorting:(PMXDataStoreViewSortingBlock)sortingBlock;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id)mappings;
- (void)setup:(void(^)(BOOL ready))completionBlock;
@property (nonatomic, strong) NSString *viewName;
@property (nonatomic, strong) NSArray *sections;

// ranges
- (void)setIsReverse:(BOOL)isReverse forGroup:(NSString*)group;
- (void)setFlexibleRangeOptions:(NSUInteger)length offset:(NSUInteger)offset from:(PMXDataStoreViewPin)viewPin maxLength:(NSUInteger)maxLength growOption:(PMXDataStoreViewGrowOptions)growOptions forGroup:(NSString *)group;
- (PMXDataStoreViewRangePosition)rangePositionForGroup:(NSString*)group;

@property (nonatomic, strong) NSString *parentViewName;

// search
@property (nonatomic, strong) NSArray *collumnNames;
@property (nonatomic, strong) NSString *searchName;
- (id)initWithCollumnNames:(NSArray*)collumnNames searchBlock:(PMXDataStoreFullTextSearchBlock)block parentViewName:(NSString*)parentViewName viewName:(NSString*)viewName sections:(NSArray*)sections;

// filter
- (id)initWithFilterBlock:(PMXDataStoreFilteringBlock)block parentViewName:(NSString*)parentViewName viewName:(NSString*)viewName sections:(NSArray*)sections;

@end

@interface UITableView (ViewMapping)

- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges;

@end

@interface UICollectionView (ViewMapping)

- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges completion:(void (^)(BOOL finished))completion;

@end
