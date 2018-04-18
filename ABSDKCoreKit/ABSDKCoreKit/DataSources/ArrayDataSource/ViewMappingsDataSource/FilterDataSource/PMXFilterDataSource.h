//
//  PMXFilteringDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 7/7/2016.
//
//

#import <PMXViewMappingsDataSource.h>

@interface PMXFilterDataSource : PMXViewMappingsDataSource

- (id)initWithName:(NSString*)name parentDataSource:(PMXViewMappingsDataSource*)parentDataSource filterBlock:(PMXDataStoreFilteringBlock)block;

@end
