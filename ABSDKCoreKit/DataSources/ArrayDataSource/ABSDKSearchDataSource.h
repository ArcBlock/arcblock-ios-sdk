//
//  ABSDKSearchViewMappingsDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 20/6/2016.
//
//

#import "ABSDKArrayDataSource.h"

@interface ABSDKSearchDataSource : ABSDKArrayDataSource

- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource collumnNames:(NSArray*)collumnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock;
- (id)initWithIdentifier:(NSString*)identifier columnNames:(NSArray*)columnNames searchBlock:(ABSDKArrayDataSourceSearchBlock)searchBlock sections:(NSArray*)sections grouping:(ABSDKArrayDataSourceGroupingBlock)grouping sorting:(ABSDKArrayDataSourceSortingBlock)sorting;
- (void)search:(NSString*)searchString;

@end
