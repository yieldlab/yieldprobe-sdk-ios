//
//  ConfigurationTests.m
//  Unit Tests
//
//  Created by Sven Herzberg on 30.10.19.
//

@import XCTest;
@import Yieldprobe;

@interface ConfigurationTests : XCTestCase

@end

@implementation ConfigurationTests

- (void)testExample {
    // Arrange:
    YLDConfiguration* configuration = [[YLDConfiguration alloc] init];
    
    // Act:
    YLDConfiguration* copy = [configuration copy];
    copy.appName = @"Amazing App";
    
    // Assert:
    XCTAssertNotEqual(copy, configuration);
    XCTAssertNotEqualObjects(copy.appName, configuration.appName);
}

@end
