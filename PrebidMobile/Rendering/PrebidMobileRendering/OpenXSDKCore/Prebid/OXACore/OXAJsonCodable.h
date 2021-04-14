//
//  OXAJsonCodable.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMConstants.h"


@protocol OXAJsonCodable <NSObject>

@property (nonatomic, strong, nullable, readonly) OXMJsonDictionary *jsonDictionary;

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
