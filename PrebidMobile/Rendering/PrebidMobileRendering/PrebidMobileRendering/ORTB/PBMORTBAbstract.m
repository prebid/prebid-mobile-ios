//
//  PBMORTBAbstract.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract+Protected.h"
#import "PBMFunctions+Private.h"
#import "PBMLog.h"

@implementation PBMORTBAbstract

// MARK: - Public

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    PBMJsonDictionary *jsonDictionary = [self toJsonDictionary];
    return [PBMFunctions toStringJsonDictionary:jsonDictionary error:error];
}

+ (instancetype)fromJsonString:(nonnull NSString *)jsonString error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    PBMJsonDictionary* dictionary = [PBMFunctions dictionaryFromJSONString:jsonString
                                                                     error:error];
    
    return [[self alloc] initWithJsonDictionary:dictionary];
}

// MARK: - <NSCopying>

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NSError *error;
    return [[self class] fromJsonString:[self toJsonStringWithError:&error] error:&error];
}

// MARK: - Protected

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMLogError(@"You must override %@ in a subclass", NSStringFromSelector(_cmd));
    return [PBMJsonDictionary new];
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    PBMLogError(@"You should not initialize abstract class directly");
    return [PBMORTBAbstract new];
}

@end
