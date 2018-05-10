//
//  ABSDKArrayDataSource.h
//  Pods
//
//  Created by Jonathan Lu on 4/9/2016.
//
//

#import <Foundation/Foundation.h>

extern NSString *const ABSDKArrayDataSourceDidUpdateNotification;

@interface ABSDKArrayDataSource : NSObject

@property (nonatomic, strong) NSArray *array;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL hasMore;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) NSInteger length;
@property (nonatomic, strong) NSArray *sections;

- (id)initWithArray:(NSArray*) array;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsForSection:(NSInteger)section;
- (id)getItemAtIndextPath:(NSIndexPath*)indexPath;
- (BOOL)isEmpty;
- (void)loadData;
- (void)refresh;
- (void)loadMore;
- (void)removeAll;
- (void)remove:(NSIndexPath*)indexPath;

@end
