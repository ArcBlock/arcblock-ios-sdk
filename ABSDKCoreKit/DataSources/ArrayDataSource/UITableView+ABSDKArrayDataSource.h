//
//  UITableView+ABSDKArrayDataSource.h
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import <UIKit/UIKit.h>

@interface UITableView (ABSDKArrayDataSource)

- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges;

@end
