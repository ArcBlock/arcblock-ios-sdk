//
//  PMXFilteringDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 7/7/2016.
//
//

#import "PMXFilterDataSource.h"

@implementation PMXFilterDataSource

- (id)initWithName:(NSString*)name parentDataSource:(PMXViewMappingsDataSource*)parentDataSource filterBlock:(PMXDataStoreFilteringBlock)block
{
    self = [super init];
    if (self) {
        self.name = name;
        self.sections = parentDataSource.sections;
        self.mappings = [[PMXDataStoreViewMappings alloc] initWithFilterBlock:block parentViewName:parentDataSource.name viewName:self.name sections:self.sections];
        [self setup];
    }
    return self;
}

- (void)setup
{
    __weak typeof(self) wself = self;
    [self.mappings setup:^(BOOL ready) {
        if (ready) {
            [[PMXDataStore sharedInstance] beginLongLivedReadTransaction];
            [wself loadData];
            wself.ready = YES;
        }
    }];
}

@end
