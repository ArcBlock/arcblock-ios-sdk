//
//  ABSDKDDPClient.h
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ABSDKDDPClientError) {
    ABSDKDDPClientErrorNetworkNotAvailable,
    ABSDKDDPClientErrorNotConnected,
    ABSDKDDPClientErrorDisconnectedBeforeCallbackComplete,
    ABSDKDDPClientErrorLogonRejected
};

extern NSString *const ABSDKDDPClientTransportErrorDomain;

typedef void(^ABSDKDDPClientMethodCallback)(NSDictionary *response, NSError *error);

@interface ABSDKDDPMethodCall : NSObject

@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic, copy) ABSDKDDPClientMethodCallback callback;

@end

@interface ABSDKDDPClient : NSObject

@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL waitingForReconnect;
@property (nonatomic, assign) BOOL isNetworkAvailable;
@property (nonatomic) NSInteger retryInterval;

- (id) initWithURLString:(NSString*)urlString;

- (NSString *)callMethodName:(NSString *)methodName parameters:(NSArray *)parameters responseCallback:(ABSDKDDPClientMethodCallback)responseCallback;
// data subscription related method, this type will be recalled whenever client got reconnected
- (void)callSubscription:(NSString *)methodName parameters:(NSArray *)parameters responseCallback:(ABSDKDDPClientMethodCallback)responseCallback;
- (void)removeSubscription:(NSString *)methodName paramters:(NSArray*)parameters;

- (void)disconnect;
- (void)reconnect;
- (void)clearMethodPool;

@end