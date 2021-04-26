//
//  PBMJsonCodable.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMConstants.h"


@protocol PBMJsonCodable <NSObject>

@property (nonatomic, strong, nullable, readonly) PBMJsonDictionary *jsonDictionary;

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
