//
//  ABSDKFilteringDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 7/7/2016.
//
//

#import "ABSDKArrayDataSource.h"

@interface ABSDKFilterDataSource : ABSDKArrayDataSource

- (id)initWithIdentifier:(NSString*)identifier parentDataSource:(ABSDKArrayDataSource*)parentDataSource filterBlock:(ABSDKArrayDataSourceFilteringBlock)block;

@end
