//
//  ABSDKViewMappingsDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 17/11/2015.
//
//

#import "ABSDKArrayDataSource.h"
#import "ABSDKViewMappings.h"

@interface ABSDKViewMappingsDataSource : ABSDKArrayDataSource

@property (nonatomic, strong) ABSDKViewMappings *mappings;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL ready;

- (id)initWithName:(NSString*)name sections:(NSArray*)sections grouping:(ABSDKViewGroupingBlock)grouping sorting:(ABSDKViewSortingBlock)sorting;
- (NSArray*)allItems;
- (void)setLength:(NSInteger)length forSection:(NSString*)section;
- (void)setReverseForSection:(NSString*)section;

@end
