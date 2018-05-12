//
//  UICollectionView+ABSDKArrayDataSource.h
//  ABSDKCoreKit
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (ABSDKArrayDataSource)

- (void)updateWithSectionChanges:(NSArray*)sectionChanges rowChanges:(NSArray*)rowChanges completion:(void (^)(BOOL finished))completion;

@end
