//
//  ABSDKSearchViewMappingsDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 20/6/2016.
//
//

#import "ABSDKViewMappingsDataSource.h"
#import "ABSDKDataStore+VIewMappings.h"

@interface ABSDKSearchDataSource : ABSDKViewMappingsDataSource

- (id)initWithParentDataSource:(ABSDKViewMappingsDataSource*)parentDataSource collumnNames:(NSArray*)collumnNames searchBlock:(ABSDKDataStoreFullTextSearchBlock)searchBlock;
- (void)search:(NSString*)searchTerm;

@end
