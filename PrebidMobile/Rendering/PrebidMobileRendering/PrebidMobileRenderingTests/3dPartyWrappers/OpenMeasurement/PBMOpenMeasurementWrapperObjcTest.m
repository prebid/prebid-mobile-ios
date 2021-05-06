//
//  OXMOpenMeasurementWrapperObjcTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PBMOpenMeasurementWrapper.h"
#import "PBMOpenMeasurementWrapper+pbmTestExtension.h"

@import PrebidMobileRendering;

@interface PBMOpenMeasurementWrapperObjcTest : XCTestCase

@end

@implementation PBMOpenMeasurementWrapperObjcTest

- (void)testInjectNilHTML {
    PBMOpenMeasurementWrapper *measurement = [PBMOpenMeasurementWrapper new];
    measurement.jsLib = @"test JS";
    
    NSString *html = nil;
    
    NSError *error;
    NSString *htmlWithMeasurementJS = [measurement injectJSLib:html error:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(htmlWithMeasurementJS);
}

@end
