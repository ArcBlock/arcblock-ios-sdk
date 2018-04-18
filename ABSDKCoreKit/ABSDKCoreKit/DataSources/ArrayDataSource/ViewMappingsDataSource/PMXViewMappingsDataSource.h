//
//  PMXViewMappingsDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 17/11/2015.
//
//

#import <PMXArrayDataSource.h>
#import "PMXDataStore.h"

@interface PMXViewMappingsDataSource : PMXArrayDataSource

@property (nonatomic, strong) PMXDataStoreViewMappings *mappings;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL ready;

- (id)initWithName:(NSString*)name sections:(NSArray*)sections grouping:(PMXDataStoreViewGroupingBlock)grouping sorting:(PMXDataStoreViewSortingBlock)sorting;
- (NSArray*)allItems;
- (void)setLength:(NSInteger)length forSection:(NSString*)section;
- (void)setReverseForSection:(NSString*)section;

@end
