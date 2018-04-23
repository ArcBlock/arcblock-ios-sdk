//
//  ABSDKView.m
//  Sprite
//
//  Created by Jonathan Lu on 12/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import "ABSDKObjectDataSource.h"

@interface ABSDKObjectDataSource ()

@end

@implementation ABSDKObjectDataSource

- (id)initWithCollectionName:(NSString*)collectionName identifier:(NSString*)identifier
{
    self = [super init];
    if (self) {
        _collectionName = collectionName;
        _identifier = identifier;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreModified:) name:ABSDKDataStoreModifiedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataStoreModified:(NSNotification *)notification
{
    if ([[ABSDKDataStore sharedInstance].registeredCollections containsObject:_collectionName]) {
        NSArray *notifications = notification.userInfo[@"notifications"];
        if (_identifier) {
            if ([[ABSDKDataStore sharedInstance] hasChangeForKey:_identifier inCollection:_collectionName inNotifications:notifications]) {
                NSLog(@"data source updated: %@, %@", _collectionName, _identifier);
                self.updated = YES;
            }
        }
    }
    else if ([notification.userInfo[@"collection"] isEqualToString:_collectionName] && [notification.userInfo[@"key"] isEqualToString:_identifier]) {
        NSLog(@"data source updated: %@, %@", _collectionName, _identifier);
        self.updated = YES;
    }
}

- (id)object{
    return [[ABSDKDataStore sharedInstance] objectForKey:_identifier inCollection:_collectionName];
}

- (void)bindWithView:(UIView*)view
{
    if ([self object]) {
        [view bindWithObject:[self object]];
    }
}

@end
