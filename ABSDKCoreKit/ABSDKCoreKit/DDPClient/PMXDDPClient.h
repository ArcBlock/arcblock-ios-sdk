//
//  PMXDDPClient.h
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import <Foundation/Foundation.h>

#define DDP_CLIENT_AUTH_KEY @"isAuth"

typedef NS_ENUM(NSUInteger, PMXDDPClientError) {
    PMXDDPClientErrorNetworkNotAvailable,
    PMXDDPClientErrorNotConnected,
    PMXDDPClientErrorNotAuthed,
    PMXDDPClientErrorDisconnectedBeforeCallbackComplete,
    PMXDDPClientErrorLogonRejected
};

extern NSString *const PMXDDPClientTransportErrorDomain;

typedef void(^PMXDDPClientMethodCallback)(NSDictionary *response, NSError *error);

@interface PMXDDPMethodCall : NSObject

@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic, copy) PMXDDPClientMethodCallback callback;

@end

@interface PMXDDPClient : NSObject

@property (nonatomic) BOOL isAuth;
@property (nonatomic) BOOL isConnecting;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL waitingForReconnect;
@property (nonatomic, assign) BOOL isNetworkAvailable;
@property (nonatomic) NSInteger retryInterval;

- (id) initWithURLString:(NSString*)urlString;

- (NSString *)callMethodName:(NSString *)methodName parameters:(NSArray *)parameters responseCallback:(PMXDDPClientMethodCallback)responseCallback;
// data subscription related method, this type will be recalled whenever client got reconnected
- (void)callSubscription:(NSString *)methodName parameters:(NSArray *)parameters responseCallback:(PMXDDPClientMethodCallback)responseCallback;
- (void)removeSubscription:(NSString *)methodName paramters:(NSArray*)parameters;

- (void)disconnect;
- (void)reconnect;
- (void)clearMethodPool;
- (void)loginWithToken;

@end
