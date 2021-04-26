//
//  PBMJsonDecodable.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMConstants.h"

// MARK: -
@protocol PBMJsonDecodable <NSObject>

- (nullable instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

// MARK: -
@protocol PBMJsonStringDecodable <PBMJsonDecodable>

- (nullable instancetype)initWithJsonString:(nonnull NSString *)jsonString
                                      error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
