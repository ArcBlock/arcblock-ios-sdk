//
//  ABSDKDDPClient.m
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import "ABSDKDDPClient.h"
#import "ObjectiveDDP.h"
#import "BSONIdGenerator.h"
#import "ABSDKDataStore.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

NSString * const ddpVersion = @"1";

NSString * const ABSDKDDPClientTransportErrorDomain = @"boundsj.objectiveddp.transport";

@implementation ABSDKDDPMethodCall

- (BOOL)isEqual:(ABSDKDDPMethodCall*)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    else {
        // as long as method name and parameter equals, consider the method calls are equal
        return [self.methodName isEqualToString:object.methodName] && ([self.parameters isEqualToArray:object.parameters] || self.parameters == object.parameters);
    }
}

@end

@interface ABSDKDDPClient () <ObjectiveDDPDelegate>

@property (nonatomic, strong) ObjectiveDDP *ddp;
@property (nonatomic, assign) BOOL websocketReady;
@property (nonatomic, strong) NSString *ddpVersion;
@property (nonatomic, strong) NSArray *supportedVersions;
@property (nonatomic, strong) NSMutableSet *methodIds;
@property (nonatomic, strong) NSMutableDictionary *responseCallbacks;
@property (nonatomic, assign) BOOL disconnecting;
@property (nonatomic, strong) NSArray *subscriptionMethods;
@property (nonatomic, strong) NSTimer *retryTimer;
@property (nonatomic) NSInteger previousRetryInterval;

@end

@implementation ABSDKDDPClient

- (id) initWithURLString:(NSString*)urlString
{
    self = [super init];
    if (self) {
        _methodIds = [NSMutableSet set];
        _responseCallbacks = [NSMutableDictionary dictionary];
        _ddpVersion = ddpVersion;
        if ([ddpVersion isEqualToString:@"1"]) {
            _supportedVersions = @[@"1", @"pre2"];
        } else {
            _supportedVersions = @[@"pre2", @"pre1"];
        }
        
        _ddp = [[ObjectiveDDP alloc] initWithURLString:urlString delegate:self];
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        self.isNetworkAvailable = (reachability.currentReachabilityStatus != NotReachable);
        
        if (self.isNetworkAvailable) {
            [_ddp connectWebSocket];
            _isConnecting = YES;
        }
        
        _previousRetryInterval = 2;
        _retryInterval = 3;
    }
    return self;
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability *reachability = notification.object;
    if ((reachability.currentReachabilityStatus == NotReachable) && self.isNetworkAvailable) {
        self.isNetworkAvailable = NO;
        self.isConnecting = NO; // no network avalibilty, not in connecting mode.
    }
    if ((reachability.currentReachabilityStatus == ReachableViaWiFi || reachability.currentReachabilityStatus == ReachableViaWWAN) && !self.isNetworkAvailable) {
        self.isNetworkAvailable = YES;
        [self reconnect];
    }
}

# pragma mark - public APIs
- (NSString *)callMethodName:(NSString *)methodName parameters:(NSArray *)parameters responseCallback:(ABSDKDDPClientMethodCallback)responseCallback
{
    if ([self _rejectIfNotConnected:methodName responseCallback:responseCallback]) {
        return nil;
    };
    NSString *methodId = [self _send:YES parameters:parameters methodName:methodName];
    if (responseCallback) {
        _responseCallbacks[methodId] = [responseCallback copy];
    }
    return methodId;

}

- (void)callSubscription:(NSString *)methodName parameters:(NSArray *)parameters responseCallback:(ABSDKDDPClientMethodCallback)responseCallback
{
    ABSDKDDPMethodCall *subscription = [[ABSDKDDPMethodCall alloc] init];
    subscription.methodName = methodName;
    subscription.parameters = parameters;
    subscription.callback = responseCallback;
    if ([_subscriptionMethods containsObject:subscription]) {
        return;
    }
    NSMutableArray *subscriptionMethods = [NSMutableArray arrayWithArray:_subscriptionMethods];
    [subscriptionMethods addObject:subscription];
    _subscriptionMethods = subscriptionMethods;
    [self callMethodName:methodName parameters:parameters responseCallback:responseCallback];
}

- (void)removeSubscription:(NSString *)methodName paramters:(NSArray*)parameters
{
    ABSDKDDPMethodCall *subscription = [[ABSDKDDPMethodCall alloc] init];
    subscription.methodName = methodName;
    subscription.parameters = parameters;
    subscription.callback = nil;
    NSMutableArray *subscriptionMethods = [NSMutableArray arrayWithArray:_subscriptionMethods];
    NSMutableArray *subscriptionsToRemove = [NSMutableArray array];
    for (ABSDKDDPMethodCall *subscription in subscriptionMethods) {
        if ([subscription.methodName isEqualToString:methodName] && [subscription.parameters isEqualToArray:parameters]) {
            [subscriptionsToRemove addObject:subscription];
            break;
        }
    }
    [subscriptionMethods removeObjectsInArray:subscriptionsToRemove];
    _subscriptionMethods = subscriptionMethods;
}

- (void)retry
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && self.isNetworkAvailable) {
        __weak typeof(self) wself = self;
        _retryInterval = _retryInterval > 30 ? 30 : _retryInterval;
        _retryTimer = [NSTimer scheduledTimerWithTimeInterval:_retryInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
            wself.waitingForReconnect = NO;
            [wself reconnect];
        }];
        self.waitingForReconnect = YES;
    }
}

- (void)disconnect {
    _disconnecting = YES;
    [self.ddp disconnectWebSocket];
}

- (void)reconnect {
    [_retryTimer invalidate];
    self.waitingForReconnect = NO;
    if (self.ddp.webSocket.readyState == SR_OPEN) {
        return;
    }
    [self.ddp connectWebSocket];
    self.isConnecting = YES;
    NSLog(@"reconnecting...");
    if (_retryInterval < 30) {
        NSInteger tmp = _retryInterval;
        _retryInterval = _previousRetryInterval + _retryInterval;
        _previousRetryInterval = tmp;
    }
}

- (void)clearMethodPool
{
    _subscriptionMethods = nil;
}

- (void)ping {
    if (!self.connected) {
        return;
    }
    [self.ddp ping:[BSONIdGenerator generate]];
}

#pragma mark <ObjectiveDDPDelegate>

- (void)didReceiveMessage:(NSDictionary *)message {
    NSString *msg = [message objectForKey:@"msg"];
    
    if (!msg) return;
    
    // TODO:  this messageId could be something invalid.
    NSString *messageId = message[@"id"];
    
#ifdef DEBUG
    NSLog(@"[DDP %@] %@", _ddp.urlString, message);
#endif
    
    if (messageId) {
        [self _handleMethodResultMessageWithMessageId:messageId message:message msg:msg];
    }
    [self _handleAddedMessage:message msg:msg];
    [self _handleRemovedMessage:message msg:msg];
    [self _handleChangedMessage:message msg:msg];
    
    if ([msg isEqualToString:@"ping"] && messageId) {
        [self.ddp pong:messageId];
    }
    else if ([msg isEqualToString:@"connected"]) {
        self.connected = YES;
        _previousRetryInterval = 2;
        _retryInterval = 3;
        NSLog(@"[DDP Server Ready] %@", _ddp.urlString);
    }
    else if ([msg isEqualToString:@"ready"]) {
        
    }
    else if ([msg isEqualToString:@"updated"]) {

    }
    else if ([msg isEqualToString:@"nosub"]) {
        
    }
    
    else if ([msg isEqualToString:@"error"]) {
        
    }
}

- (void)didOpen {
    self.websocketReady = YES;
    [self.ddp connectWithSession:nil version:self.ddpVersion support:self.supportedVersions];
    NSLog(@"[Connected] %@", _ddp.urlString);
}

- (void)didReceiveConnectionError:(NSError *)error {
    [self _handleConnectionError];
}

- (void)didReceiveConnectionClose {
    [self _handleConnectionError];
}

#pragma mark - parse response

- (void)_handleMethodResultMessageWithMessageId:(NSString *)messageId message:(NSDictionary *)message msg:(NSString *)msg {
    if ([_methodIds containsObject:messageId] && [msg isEqualToString:@"result"]) {
        ABSDKDDPClientMethodCallback callback = _responseCallbacks[messageId];
        id response;
        if(message[@"error"]) {
            NSError *responseError = [NSError errorWithDomain:@"DDP_METHOD_ERROR" code:-1 userInfo:message[@"error"]];
            if (callback) {
                callback(nil, responseError);
            }
            response = responseError;
        } else {
            if (callback) {
                callback(message, nil);
            }
        }
        [_responseCallbacks removeObjectForKey:messageId];
        [_methodIds removeObject:messageId];
    }
}

- (void)_handleAddedMessage:(NSDictionary *)message msg:(NSString *)msg {
    if ([msg isEqualToString:@"added"]
        && message[@"collection"]) {
        [self upsertMessage:message];
    }
}

- (void)_handleRemovedMessage:(NSDictionary *)message msg:(NSString *)msg {
    if ([msg isEqualToString:@"removed"]
        && message[@"collection"]) {
        if (!message[@"id"]) {
            return;
        }
        [[ABSDKDataStore sharedInstance] removeObjectForKey:message[@"id"] inCollection:message[@"collection"] completionBlock:nil];
    }
}

- (void)_handleChangedMessage:(NSDictionary *)message msg:(NSString *)msg {
    if ([msg isEqualToString:@"changed"]
        && message[@"collection"]) {
        
        [self upsertMessage:message];
    }
}

- (void)upsertMessage:(NSDictionary*)message
{
    // make sure this is a valid message
    if (([message objectForKey:@"id"] == nil) || ([message objectForKey:@"id"] == [NSNull null])) {
        NSLog(@"Warning! Received an invalid message: %@", message);
        return;
    }
    
    if ([[ABSDKDataStore sharedInstance] objectForKey:message[@"id"] inCollection:message[@"collection"]]) {
        NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:[[ABSDKDataStore sharedInstance] objectForKey:message[@"id"] inCollection:message[@"collection"]]];
        for (id key in message[@"fields"]) {
            object[key] = message[@"fields"][key];
        }
        for (id key in message[@"cleared"]) {
            [object removeObjectForKey:key];
        }
        [[ABSDKDataStore sharedInstance] setObject:object forKey:message[@"id"] inCollection:message[@"collection"] completionBlock:nil];
    }
    else {
        NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"_id": message[@"id"]}];
        for (id key in message[@"fields"]) {
            object[key] = message[@"fields"][key];
        }
        for (id key in message[@"cleared"]) {
            [object removeObjectForKey:key];
        }
        [[ABSDKDataStore sharedInstance] setObject:object forKey:message[@"id"] inCollection:message[@"collection"] completionBlock:nil];
    }
}

# pragma mark - private methods

- (BOOL)okToSend {
    if (!self.connected) {
        return NO;
    }
    return YES;
}

- (NSString *)_send:(BOOL)notify parameters:(NSArray *)parameters methodName:(NSString *)methodName {
    NSString *methodId = [BSONIdGenerator generate];
    if(notify == YES) {
        [_methodIds addObject:methodId];
    }
    [self.ddp methodWithId:methodId
                    method:methodName
                parameters:parameters];
    return methodId;
}

- (void)_handleConnectionError {
    self.isConnecting = NO;
    self.websocketReady = NO;
    self.connected = NO;
    [self _invalidateUnresolvedMethods];
    NSLog(@"[Disconnected] %@", _ddp.urlString);
    if (_disconnecting) {
        _disconnecting = NO;
        return;
    }
    [self retry];
}

- (BOOL)_rejectIfNotConnected:(NSString*)methodName responseCallback:(ABSDKDDPClientMethodCallback)responseCallback {
    if (!_isNetworkAvailable) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Network is not available"};
        NSError *notConnectedError = [NSError errorWithDomain:ABSDKDDPClientTransportErrorDomain code:ABSDKDDPClientErrorNetworkNotAvailable userInfo:userInfo];
        if (responseCallback) {
            responseCallback(nil, notConnectedError);
        }
        return YES;
    }
    else if (![self okToSend]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"You are not connected"};
        NSError *notConnectedError = [NSError errorWithDomain:ABSDKDDPClientTransportErrorDomain code:ABSDKDDPClientErrorNotConnected userInfo:userInfo];
        if (responseCallback) {
            responseCallback(nil, notConnectedError);
        }
        return YES;
    }
    return NO;
}

- (void)_invalidateUnresolvedMethods {
    for (NSString *methodId in _methodIds) {
        ABSDKDDPClientMethodCallback callback = _responseCallbacks[methodId];
        if (callback) {
            callback(nil, [NSError errorWithDomain:ABSDKDDPClientTransportErrorDomain code:ABSDKDDPClientErrorDisconnectedBeforeCallbackComplete userInfo:@{NSLocalizedDescriptionKey: @"You were disconnected"}]);
        }
    }
    [_methodIds removeAllObjects];
    [_responseCallbacks removeAllObjects];
}

@end
