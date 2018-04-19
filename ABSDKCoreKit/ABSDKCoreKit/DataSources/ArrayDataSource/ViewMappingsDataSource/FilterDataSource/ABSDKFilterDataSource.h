//
//  ABSDKFilteringDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 7/7/2016.
//
//

#import <ABSDKViewMappingsDataSource.h>

@interface ABSDKFilterDataSource : ABSDKViewMappingsDataSource

- (id)initWithName:(NSString*)name parentDataSource:(ABSDKViewMappingsDataSource*)parentDataSource filterBlock:(ABSDKDataStoreFilteringBlock)block;

@end
