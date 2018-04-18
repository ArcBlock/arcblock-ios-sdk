//
//  PMXView.m
//  Sprite
//
//  Created by Jonathan Lu on 12/11/2015.
//  Copyright © 2015 Pixomobile. All rights reserved.
//

#import "PMXObjectDataSource.h"

@interface PMXObjectDataSource ()

@end

@implementation PMXObjectDataSource

- (id)initWithCollectionName:(NSString*)collectionName identifier:(NSString*)identifier
{
    self = [super init];
    if (self) {
        _collectionName = collectionName;
        _identifier = identifier;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataStoreModified:) name:PMXDataStoreModifiedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataStoreModified:(NSNotification *)notification
{
    if ([[PMXDataStore sharedInstance].collectionsInDatabase containsObject:_collectionName]) {
        NSArray *notifications = notification.userInfo[@"notifications"];
        if (!notifications.count) {
            return;
        }
        if (_identifier) {
            if ([[PMXDataStore sharedInstance] hasChangeForKey:_identifier inCollection:_collectionName inNotifications:notifications]) {
                NSLog(@"data source updated: %@, %@", _collectionName, _identifier);
                self.updated = YES;
            }
        }
    }
    else {
        if ([notification.userInfo[@"collection"] isEqualToString:_collectionName] && [notification.userInfo[@"key"] isEqualToString:_identifier]) {
            NSLog(@"data source updated: %@, %@", _collectionName, _identifier);
            self.updated = YES;
        }
    }
}

- (id)object{
    return [[PMXDataStore sharedInstance] objectForKey:_identifier inCollection:_collectionName];
}

- (void)bindWithView:(UIView*)view
{
    if ([self object]) {
        [view bindWithObject:[self object]];
    }
}

@end
