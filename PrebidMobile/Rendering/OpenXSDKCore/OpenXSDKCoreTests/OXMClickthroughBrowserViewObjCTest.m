//
//  OXMClickthroughBrowserViewObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OXMClickthroughBrowserView.h"
#import "OXMFunctions+Private.h"

@interface OXMClickthroughBrowserViewObjCTest : XCTestCase

@property (nonatomic, strong) OXMClickthroughBrowserView* view;

@end

@implementation OXMClickthroughBrowserViewObjCTest

#pragma mark - SetUp

- (void)setUp {
    [super setUp];
    
    self.view = [[OXMFunctions.bundleForSDK loadNibNamed:@"ClickthroughBrowserView" owner:nil options:nil] firstObject];
}

- (void)tearDown {
    self.view = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testLoadNilURL {
    NSURL *url = nil;
    [self.view openURL:url completion:^(BOOL shouldBeDisplayed) {
        XCTAssertFalse(shouldBeDisplayed);
    }];
    
    XCTAssertNil(self.view.webView.URL);
}

@end
