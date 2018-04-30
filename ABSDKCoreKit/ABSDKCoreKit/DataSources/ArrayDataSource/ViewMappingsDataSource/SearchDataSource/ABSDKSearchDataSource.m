//
//  ABSDKSearchViewMappingsDataSource.m
//  Pods
//
//  Created by Jonathan Lu on 20/6/2016.
//
//

#import "ABSDKSearchDataSource.h"
#import "ABSDKDataStore+ViewMappings.h"

@implementation ABSDKSearchDataSource

- (id)initWithParentDataSource:(ABSDKViewMappingsDataSource*)parentDataSource collumnNames:(NSArray*)collumnNames searchBlock:(ABSDKDataStoreFullTextSearchBlock)searchBlock
{
    self = [super init];
    if (self) {
        self.name = [NSString stringWithFormat:@"%@-search", parentDataSource.name];
        self.sections = parentDataSource.sections;
        self.mappings = [[ABSDKViewMappings alloc] initWithCollumnNames:collumnNames searchBlock:searchBlock parentViewName:parentDataSource.name viewName:self.name sections:self.sections];
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

- (void)search:(NSString*)searchTerm
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    
    NSArray *searchComponents = [searchTerm componentsSeparatedByCharactersInSet:whitespace];
    NSMutableString *query = [NSMutableString string];
    
    for (NSString *term in searchComponents)
    {
        if ([term length] > 0)
            [query appendString:@""];
        
        [query appendFormat:@"%@*", term];
    }
    NSLog(@"%@", query);
    [[ABSDKDataStore sharedInstance] search:query viewMappings:self.mappings];
}

@end
