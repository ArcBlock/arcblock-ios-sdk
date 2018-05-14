//
//  ABSDKView.h
//  Sprite
//
//  Created by Jonathan Lu on 12/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+ABSDKKVBinding.h"

@interface ABSDKObjectDataSource : NSObject

@property (nonatomic, strong, readonly) NSString *collection;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, readonly) BOOL updated;

+ (ABSDKObjectDataSource*)objectDataSourceWithCollection:(NSString*)collection key:(NSString*)key;
- (id)fetchObject;

@end
