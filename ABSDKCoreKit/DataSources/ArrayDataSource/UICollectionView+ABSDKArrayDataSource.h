//
//  UICollectionView+ABSDKArrayDataSource.h
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import <UIKit/UIKit.h>
#import "ABSDKArrayDataSource.h"

@interface UICollectionView (ABSDKArrayDataSource)

- (void)observeArrayDataSource:(ABSDKArrayDataSource*)arrayDataSource updatedBlock:(void (^)(void))updatedBlock;
- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges completion:(void (^)(BOOL finished))completion;

@end
