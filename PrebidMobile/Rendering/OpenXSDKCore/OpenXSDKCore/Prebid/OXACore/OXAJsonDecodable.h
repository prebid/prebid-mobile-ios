//
//  OXAJsonDecodable.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "OXMConstants.h"

// MARK: -
@protocol OXAJsonDecodable <NSObject>

- (nullable instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

// MARK: -
@protocol OXAJsonStringDecodable <OXAJsonDecodable>

- (nullable instancetype)initWithJsonString:(nonnull NSString *)jsonString
                                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
