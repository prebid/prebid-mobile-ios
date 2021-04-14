//
//  OXMORTBAbstract.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract+Protected.h"
#import "OXMFunctions+Private.h"
#import "OXMLog.h"

@implementation OXMORTBAbstract

// MARK: - Public

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    OXMJsonDictionary *jsonDictionary = [self toJsonDictionary];
    return [OXMFunctions toStringJsonDictionary:jsonDictionary error:error];
}

+ (instancetype)fromJsonString:(nonnull NSString *)jsonString error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    OXMJsonDictionary* dictionary = [OXMFunctions dictionaryFromJSONString:jsonString
                                                                     error:error];
    
    return [[self alloc] initWithJsonDictionary:dictionary];
}

// MARK: - <NSCopying>

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NSError *error;
    return [[self class] fromJsonString:[self toJsonStringWithError:&error] error:&error];
}

// MARK: - Protected

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMLogError(@"You must override %@ in a subclass", NSStringFromSelector(_cmd));
    return [OXMJsonDictionary new];
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    OXMLogError(@"You should not initialize abstract class directly");
    return [OXMORTBAbstract new];
}

@end
