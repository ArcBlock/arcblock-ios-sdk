//
//  PMXSearchViewMappingsDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 20/6/2016.
//
//

#import <PMXViewMappingsDataSource.h>
#import "PMXDataStore.h"

@interface PMXSearchDataSource : PMXViewMappingsDataSource

- (id)initWithParentDataSource:(PMXViewMappingsDataSource*)parentDataSource collumnNames:(NSArray*)collumnNames searchBlock:(PMXDataStoreFullTextSearchBlock)searchBlock;
- (void)search:(NSString*)searchTerm;

@end
