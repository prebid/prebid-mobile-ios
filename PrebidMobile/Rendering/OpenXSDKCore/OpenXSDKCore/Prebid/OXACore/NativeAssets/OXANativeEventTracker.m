//
//  OXANativeEventTracker.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeEventTracker.h"
#import "OXANativeEventTracker+Internal.h"

#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"

#import "NSDictionary+OXAORTBNativeExt.h"
#import "NSNumber+OXAORTBNative.h"

@interface OXANativeEventTracker ()
@property (nonatomic, strong) NSArray<NSNumber *> *rawMethods;
@end



@implementation OXANativeEventTracker

- (instancetype)initWithEvent:(OXANativeEventType)event methods:(NSArray<NSNumber *> *)methods {
    if (!(self = [super init])) {
        return nil;
    }
    _event = event;
    _methods = [methods copy];
    return self;
}

// MARK: - Private Properties

- (NSArray<NSNumber *> *)rawMethods {
    return _methods;
}

- (void)setRawMethods:(NSArray<NSNumber *> *)rawMethods {
    _methods = rawMethods;
}

- (void)setExt:(nullable NSDictionary<NSString *, id> *)ext {
    _ext = ext;
}

// MARK: - Ext

- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSError *localError = nil;
    OXMJsonDictionary * const newExt = [ext unserializedCopyWithError:&localError];
    if (error) {
        *error = localError;
    }
    if (localError) {
        return NO;
    }
    _ext = newExt;
    return YES;
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    OXANativeEventTracker * const clone = [[OXANativeEventTracker alloc] initWithEvent:self.event methods:@[]];
    clone.rawMethods = self.rawMethods;
    clone.ext = self.ext;
    return clone;
}

// MARK: - OXAJsonCodable

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    return [OXMFunctions toStringJsonDictionary:self.jsonDictionary error:error];
}

- (nullable OXMJsonDictionary *)jsonDictionary {
    OXMMutableJsonDictionary * const result = [[OXMMutableJsonDictionary alloc] init];
    result[@"event"] = @(self.event);
    result[@"ext"] = self.ext;
    if (self.methods) {
        NSMutableArray * const newMethods = [[NSMutableArray alloc] initWithCapacity:self.methods.count];
        for(NSNumber *nextMethod in self.methods) {
            [newMethods addObject:nextMethod.integerNumber];
        }
        result[@"methods"] = newMethods;
    }
    return result;
}

@end
