//
//  UITableView+ABSDKArrayDataSource.h
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import <UIKit/UIKit.h>
#import "ABSDKArrayDataSource.h"

@interface UITableView (ABSDKArrayDataSource)

- (void)observeArrayDataSource:(ABSDKArrayDataSource*)arrayDataSource updatedBlock:(void (^)(void))updatedBlock;
- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges;

@end
