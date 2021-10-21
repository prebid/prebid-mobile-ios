/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "PBMClickthroughBrowserView.h"
#import "PBMFunctions.h"

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
