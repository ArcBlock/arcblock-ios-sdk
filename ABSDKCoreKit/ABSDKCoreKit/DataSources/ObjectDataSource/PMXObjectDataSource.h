//
//  PMXView.h
//  Sprite
//
//  Created by Jonathan Lu on 12/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMXDataStore.h"
#import "UIView+KVBinding.h"
#import "UIImageView+KVBinding.h"

#define  UPDATED_KEYPATH    @"updated"

@interface PMXObjectDataSource : NSObject

@property (nonatomic, strong) NSString *collectionName;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) BOOL updated;         // key for KVO

- (id)initWithCollectionName:(NSString*)collectionName identifier:(NSString*)identifier;

- (void)bindWithView:(UIView*)view;
- (id)object;

@end