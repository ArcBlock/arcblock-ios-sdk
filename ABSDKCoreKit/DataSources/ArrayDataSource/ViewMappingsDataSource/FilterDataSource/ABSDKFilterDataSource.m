//
//  ABSDKFilteringDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 7/7/2016.
//
//

#import "ABSDKFilterDataSource.h"

@implementation ABSDKFilterDataSource

- (id)initWithName:(NSString*)name parentDataSource:(ABSDKViewMappingsDataSource*)parentDataSource filterBlock:(ABSDKDataStoreFilteringBlock)block
{
    self = [super init];
    if (self) {
        self.name = name;
        self.sections = parentDataSource.sections;
        self.mappings = [[ABSDKViewMappings alloc] initWithFilterBlock:block parentViewName:parentDataSource.name viewName:self.name sections:self.sections];
        [self setup];
    }
    return self;
}

- (void)setup
{
    __weak typeof(self) wself = self;
    [self.mappings setup:^(BOOL ready) {
        if (ready) {
            [wself loadData];
            wself.ready = YES;
        }
    }];
}

@end
