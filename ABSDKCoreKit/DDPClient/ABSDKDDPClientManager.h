//
//  ABSDKDDPClientManager.h
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import <Foundation/Foundation.h>
#import "ABSDKDDPClient.h"

@interface ABSDKDDPClientManager : NSObject

+ (ABSDKDDPClientManager*) sharedInstance;
- (ABSDKDDPClient*) clientFromURLString:(NSString*)urlString;

@end
