//
//  OXMBundleProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

//Like UIApplication, Bundle is a bit tricky to mock, so we make this special
//protocol that Bundle already conforms to and apply it to Bundle.
@protocol OXMBundleProtocol

@property(readonly, copy, nullable) NSDictionary<NSString *,id> * infoDictionary;
@property(readonly, copy, nullable) NSString * bundleIdentifier;

@end

@interface NSBundle () <OXMBundleProtocol>
@end

