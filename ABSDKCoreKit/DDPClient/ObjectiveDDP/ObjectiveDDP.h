#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

@protocol ObjectiveDDPDelegate;

@interface ObjectiveDDP : NSObject <SRWebSocketDelegate>

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) id <ObjectiveDDPDelegate> delegate;
@property (nonatomic, strong) SRWebSocket *webSocket;

- (void)ping:(NSString *)id;
- (void)pong:(NSString *)id;

// Prevent user from start with this methods
- (id)init __attribute__((unavailable("Must use initWithURLString:delegate: instead.")));
+ (instancetype)new __attribute__((unavailable("Must use initWithURLString:delegate: instead.")));

- (id)initWithURLString:(NSString *)urlString delegate:(id <ObjectiveDDPDelegate>)delegate;
- (void)connectWebSocket;
- (void)disconnectWebSocket;
- (void)connectWithSession:(NSString *)session version:(NSString *)version support:(NSArray *)support;
- (void)subscribeWith:(NSString *)id name:(NSString *)name parameters:(NSArray *)parameters;
- (void)unsubscribeWith:(NSString *)id;
- (void)methodWithId:(NSString *)id method:(NSString *)method parameters:(NSArray *)parameters;

@end

@protocol ObjectiveDDPDelegate

- (void)didOpen;
- (void)didReceiveMessage:(NSDictionary *)message;
- (void)didReceiveConnectionError:(NSError *)error;
- (void)didReceiveConnectionClose;

@end
