//
//  ABSDKCoreKitTests.m
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 17/4/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ABSDKDataStore.h"

@interface ABSDKDataStoreTests : XCTestCase

@end

@implementation ABSDKDataStoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ABSDKDataStore sharedInstance] registerCollections:@[@"users"]];
    [[ABSDKDataStore sharedInstance] setupDataStore:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[ABSDKDataStore sharedInstance] quitDataStore];
}

- (void)testWriteToDatabase {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *databaseWriteExpectation = [self expectationWithDescription:@"write to database"];
    NSDictionary *testUserObject = @{@"name": @"Jonathan Lu"};
    NSString *testUserKey = @"joluv";
    [[ABSDKDataStore sharedInstance] setObject:testUserObject forKey:testUserKey inCollection:@"users" completionBlock:^{
        XCTAssertEqualObjects(testUserObject, [[ABSDKDataStore sharedInstance] objectForKey:testUserKey inCollection:@"users"], @"Write to database failed");
        [databaseWriteExpectation fulfill];
    }];
    
    [self waitForExpectations:@[databaseWriteExpectation] timeout:1];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
