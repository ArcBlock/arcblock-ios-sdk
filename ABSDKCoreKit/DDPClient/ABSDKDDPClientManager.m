//
//  ABSDKDDPClientManager.m
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import <UIKit/UIKit.h>
#import "ABSDKDDPClientManager.h"

@interface ABSDKDDPClientManager ()

@property (nonatomic, strong) NSMutableDictionary *ddpClients;

@end

@implementation ABSDKDDPClientManager

+ (ABSDKDDPClientManager*) sharedInstance
{
    static ABSDKDDPClientManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ABSDKDDPClientManager alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _ddpClients = [NSMutableDictionary dictionary];
        
        // we will need to check if we need reconnect when application become active.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (ABSDKDDPClient*) clientFromURLString:(NSString*)urlString
{
    if ([_ddpClients objectForKey:urlString] != nil) {
        return (ABSDKDDPClient*)[_ddpClients objectForKey:urlString];
    }
    else {
        ABSDKDDPClient* client = [[ABSDKDDPClient alloc] initWithURLString:urlString];
        [_ddpClients setObject:client forKey:urlString];
        return client;
    }
}

- (void) reconnect
{
    for (ABSDKDDPClient *client in [_ddpClients allValues]) {
        if (client && !client.connected && !client.isConnecting) {
            [client reconnect];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive
{
    NSLog(@"[ABSDKDDPClientManager] applicationDidBecomeActive, will try to reconnect client if any connection get lost");
    [self reconnect];
}

@end
