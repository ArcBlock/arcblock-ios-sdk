//
//  PMXDDPClientManager.h
//  Pods
//
//  Created by Jonathan Lu on 19/11/2015.
//
//

#import <Foundation/Foundation.h>
#import "PMXDDPClient.h"

@interface PMXDDPClientManager : NSObject

+ (PMXDDPClientManager*) sharedInstance;
- (PMXDDPClient*) clientFromURLString:(NSString*)urlString;

@end
