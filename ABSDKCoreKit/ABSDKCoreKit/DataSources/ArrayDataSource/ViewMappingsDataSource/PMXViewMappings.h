//
//  PMXArrayDataMappings.h
//  Pods
//
//  Created by Jonathan Lu on 29/12/2015.
//
//

#import <UIKit/UIKit.h>

struct PMXViewRangePosition {
    NSUInteger offsetFromBeginning;
    NSUInteger offsetFromEnd;
    NSUInteger length;
    
};
typedef struct PMXViewRangePosition PMXViewRangePosition;

typedef NS_ENUM(NSInteger, PMXViewPin) {
    PMXViewBeginning = 0,
    PMXViewEnd       = 1,
};

typedef NS_OPTIONS(NSUInteger, PMXViewGrowOptions) {
    PMXViewGrowPinSide    = 1 << 0,
    PMXViewGrowNonPinSide = 1 << 1,
    PMXViewGrowInRangeOnly = 0,
    PMXViewGrowOnBothSides = (PMXViewGrowPinSide | PMXViewGrowNonPinSide)
};

typedef NSString* (^PMXViewGroupingBlock)(id transaction, NSString *collection, NSString *key, id object);
typedef NSComparisonResult (^PMXViewSortingBlock) (id transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2);
typedef BOOL (^PMXDataStoreFilteringBlock)(id transaction, NSString *group, NSString *collection, NSString *key, id object);
typedef void (^PMXDataStoreFullTextSearchBlock)(NSMutableDictionary *dict, NSString *collection, NSString *key, id object);

@interface PMXViewMappings : NSObject

// basics
- (id)initWithViewName:(NSString*)viewName sections:(NSArray*)sections grouping:(PMXViewGroupingBlock)groupingBlock sorting:(PMXViewSortingBlock)sortingBlock;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id)mappings;
- (void)setup:(void(^)(BOOL ready))completionBlock;
@property (nonatomic, strong) NSString *viewName;
@property (nonatomic, strong) NSArray *sections;

// ranges
- (void)setIsReverse:(BOOL)isReverse forGroup:(NSString*)group;
- (void)setFlexibleRangeOptions:(NSUInteger)length offset:(NSUInteger)offset from:(PMXViewPin)viewPin maxLength:(NSUInteger)maxLength growOption:(PMXViewGrowOptions)growOptions forGroup:(NSString *)group;
- (PMXViewRangePosition)rangePositionForGroup:(NSString*)group;

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
