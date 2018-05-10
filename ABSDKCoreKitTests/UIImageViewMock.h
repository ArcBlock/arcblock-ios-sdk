//
//  UIImageViewMock.h
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 10/5/2018.
//

#import <UIKit/UIKit.h>
#import "UIImageView+ABSDKKVBinding.h"

@interface UIImageViewMock : UIImageView

- (id)initWithMockURL:(NSString*)url image:(UIImage*)image;

@end
