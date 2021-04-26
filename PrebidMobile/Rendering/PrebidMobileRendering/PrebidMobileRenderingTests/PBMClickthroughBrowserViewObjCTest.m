//
//  PBMClickthroughBrowserViewObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PBMClickthroughBrowserView.h"
#import "PBMFunctions+Private.h"

@interface PBMClickthroughBrowserViewObjCTest : XCTestCase

@property (nonatomic, strong) PBMClickthroughBrowserView* view;

@end

@implementation PBMClickthroughBrowserViewObjCTest

#pragma mark - SetUp

- (void)setUp {
    [super setUp];
    
    self.view = [[PBMFunctions.bundleForSDK loadNibNamed:@"ClickthroughBrowserView" owner:nil options:nil] firstObject];
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
