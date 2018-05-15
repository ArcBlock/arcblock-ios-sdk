//
//  ABSDKArrayDataSource+Private.h
//  ArcBlockSDK
//
//  Created by Jonathan Lu on 14/5/2018.
//

#import "ABSDKArrayDataSource.h"
#import <YapDatabase/YapDatabaseView.h>

@interface ABSDKArrayDataSource (Private)

@property (nonatomic, strong) YapDatabaseView *databaseView;

- (void)setupView;
- (void)resetView;

@end
