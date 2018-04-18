//
//  PMXDDPClientManager.m
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import "PMXDDPClientManager.h"

@interface PMXDDPClientManager ()

@property (nonatomic, strong) NSMutableDictionary *ddpClients;

@end

@implementation PMXDDPClientManager

+ (PMXDDPClientManager*) sharedInstance
{
    static PMXDDPClientManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PMXDDPClientManager alloc] init];
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

- (PMXDDPClient*) clientFromURLString:(NSString*)urlString
{
    if ([_ddpClients objectForKey:urlString] != nil) {
        return (PMXDDPClient*)[_ddpClients objectForKey:urlString];
    }
    else {
        PMXDDPClient* client = [[PMXDDPClient alloc] initWithURLString:urlString];
        [_ddpClients setObject:client forKey:urlString];
        return client;
    }
}

- (void) reconnect
{
    for (PMXDDPClient *client in [_ddpClients allValues]) {
        if (client && !client.isAuth && !client.isConnecting) {
            if (!client.connected) {
                [client reconnect];
            }
            else if (!client.isAuth) {
                [client loginWithToken];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive
{
    NSLog(@"[PMXDDPClientManager] applicationDidBecomeActive, will try to reconnect client if any connection get lost");
    [self reconnect];
}

@end
