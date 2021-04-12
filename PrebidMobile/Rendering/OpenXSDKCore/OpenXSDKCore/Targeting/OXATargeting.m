//
//  OXATargeting.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "OXATargeting.h"
#import "OXAAgeUtils.h"
#import "OXATargeting+Private.h"
#import "OXATargeting+InternalState.h"

#import "OXMConstants.h"
#import "OXMLog.h"
#import "OXMORTB.h"
#import "OXMORTBBidRequest.h"

// MARK: - Enum Keys
static NSString * const OXATargetingKey_AGE = @"age";
static NSString * const OXATargetingKey_CARRIER = @"crr";
static NSString * const OXATargetingKey_GENDER = @"gen";
static NSString * const OXATargetingKey_IP_ADDRESS = @"ip";
static NSString * const OXATargetingKey_NETWORK_TYPE = @"net";
static NSString * const OXATargetingKey_USER_ID = @"xid";
static NSString * const OXATargetingKey_PUB_PROVIDED_PREFIX = @"c.";

// MARK: - Private Properties

@interface OXATargeting()

@property (nonatomic, strong, nonnull, readonly) id<NSLocking> parameterDictionaryLock;

@property (nonatomic, strong, nonnull) NSMutableSet<NSString *> *rawAccessControlList;
@property (nonatomic, strong, nonnull, readonly) NSMutableDictionary<NSString *, NSSet<NSString *> *> *rawUserDataDictionary;
@property (nonatomic, strong, nonnull, readonly) NSMutableDictionary<NSString *, NSSet<NSString *> *> *rawContextDataDictionary;

@end



#pragma mark - Implementation

@implementation OXATargeting

#pragma mark - Initialization

+ (instancetype)shared {
    static OXATargeting *singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[OXATargeting alloc] init];
    });

    return singleton;
}

- (instancetype)init {
    return (self = [self initWithParameters:@{} coordinate:nil]);
}

- (instancetype)initWithParameters:(NSDictionary<NSString *, NSString *> *)parameters
                        coordinate:(nullable NSValue *)coordinate
{
    if (!(self = [super init])) {
        return nil;
    }
    _parameterDictionary = [parameters mutableCopy];
    _parameterDictionaryLock = [[NSRecursiveLock alloc] init];
    _coordinate = coordinate;
    _rawAccessControlList = [[NSMutableSet alloc] init];
    _rawUserDataDictionary = [[NSMutableDictionary alloc] init];
    _rawContextDataDictionary = [[NSMutableDictionary alloc] init];
    
    return self;
}

#pragma mark - Thread safe dictionary access

- (void)performSafeParamsAccess:(void (^_Nonnull)(void))accessBlock {
    if (self.disableLockUsage) {
        accessBlock();
        return;
    }
    const id<NSLocking> lock = self.parameterDictionaryLock;
    [lock lock];
    accessBlock();
    [lock unlock];
}

- (void)setThreadSafeValue:(nullable NSString *)value forKey:(nonnull NSString *)key {
    [self performSafeParamsAccess:^{
        self.parameterDictionary[key] = value;
    }];
}

- (nullable NSString *)threadSafeValueForKey:(nonnull NSString *)key {
    NSString * __block result = nil;
    [self performSafeParamsAccess:^{
        result = self.parameterDictionary[key];
    }];
    return result;
}

- (NSDictionary<NSString *, NSString *> *)parameterDictionaryCopy {
    NSDictionary<NSString *, NSString *> * __block result = nil;
    [self performSafeParamsAccess:^{
        result = [self.parameterDictionary copy];
    }];
    return result;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    OXATargeting * __block clone = nil;
    [self performSafeParamsAccess:^{
        clone = [[OXATargeting alloc] initWithParameters:self.parameterDictionary coordinate:self.coordinate];
        clone.coppa = self.coppa;
        clone.buyerUID = self.buyerUID;
        clone.keywords = self.keywords;
        clone.userCustomData = self.userCustomData;
        clone.contentUrl = self.contentUrl;
        clone.publisherName = self.publisherName;
        clone.sourceapp = self.sourceapp;
        clone.eids = [self.eids copy];
        clone.userExt = [self.userExt copy];
        for (NSString *bidderName in self.rawAccessControlList) {
            [clone.rawAccessControlList addObject:bidderName];
        }
        [clone.rawUserDataDictionary addEntriesFromDictionary:self.rawUserDataDictionary];
        [clone.rawContextDataDictionary addEntriesFromDictionary:self.rawContextDataDictionary];
    }];
    return clone;
}

#pragma mark - NSLocking

- (void)lock {
    [self.parameterDictionaryLock lock];
}

- (void)unlock {
    [self.parameterDictionaryLock unlock];
}

#pragma mark - User Information

- (NSInteger)userAge {
    return [self threadSafeValueForKey:OXATargetingKey_AGE].integerValue;
}

- (void)setUserAge:(NSInteger)userAge {
    [self setThreadSafeValue:@(userAge).stringValue forKey:OXATargetingKey_AGE];
}

- (OXAGender)userGender {
    NSString * const currentGender = [self threadSafeValueForKey:OXATargetingKey_GENDER];
    return oxaGenderFromDescription(currentGender);
}

- (void)setUserGender:(OXAGender)userGender {
    [self setThreadSafeValue:oxaDescriptionOfGender(userGender) forKey:OXATargetingKey_GENDER];
}

- (OXAGenderDescription)userGenderDescription {
    return [self threadSafeValueForKey:OXATargetingKey_GENDER];
}

- (nullable NSString *)userID {
    return [self threadSafeValueForKey:OXATargetingKey_USER_ID];
}

- (void)setUserID:(NSString *)userID {
    [self setThreadSafeValue:[userID copy] forKey:OXATargetingKey_USER_ID];
}

#pragma mark - Application Information

- (nullable NSString *)appStoreMarketURL {
    return [self threadSafeValueForKey:OXMParameterKeysAPP_STORE_URL];
}

- (void)setAppStoreMarketURL:(NSString *)appStoreMarketURL {
    [self setThreadSafeValue:[appStoreMarketURL copy] forKey:OXMParameterKeysAPP_STORE_URL];
}

#pragma mark - Location and connection information

#pragma - Network

- (nullable NSString *)IP {
    return [self threadSafeValueForKey:OXATargetingKey_IP_ADDRESS];
}

- (void) setIP:(NSString *)IP {
    [self setThreadSafeValue:[IP copy] forKey:OXATargetingKey_IP_ADDRESS];
}

- (nullable NSString *)carrier {
    return [self threadSafeValueForKey:OXATargetingKey_CARRIER];
}

- (void)setCarrier:(NSString *)carrier {
    [self setThreadSafeValue:[carrier copy] forKey:OXATargetingKey_CARRIER];
}

- (OXANetworkType)networkType {
    NSString * const currentNetworkType = [self threadSafeValueForKey:OXATargetingKey_NETWORK_TYPE];
    return oxaNetworkTypeFromDescription(currentNetworkType);
}

- (void)setNetworkType:(OXANetworkType)networkType {
    NSString * const objectToSave = (networkType == OXANetworkTypeUnknown
                                     ? nil
                                     : oxaDescriptionOfNetworkType(networkType));
    [self setThreadSafeValue:objectToSave forKey:OXATargetingKey_NETWORK_TYPE];
}

#pragma mark - Methods

- (void)resetUserAge {
    self.userAge = 0;
    [self setThreadSafeValue:nil forKey:OXATargetingKey_AGE];
}

- (void)addParam:(nonnull NSString *)value withName:(nonnull NSString *)name {
    if (!name) {
        OXMLogError(@"Invalid user parameter.");
        return;
    }
    
    if ([value isEqualToString:@""]) {
        [self setThreadSafeValue:nil forKey:name];
    } else {
        [self setThreadSafeValue:value forKey:name];
    }
}

- (void)setCustomParams:(nullable NSDictionary<NSString *, NSString *> *)params {
    for (NSString *key in params.allKeys) {
        [self addCustomParam:params[key] withName:key];
    }
}

- (void)addCustomParam:(nonnull NSString *)value withName:(nonnull NSString *)name {
    NSString * prefixedName = [self makeCustomParamFromName:name];
    [self addParam:value withName:prefixedName];
}

// Store location in the user's section
- (void)setLatitude:(double)latitude longitude:(double)longitude {
    self.coordinate = [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

#pragma mark - Access Control List

- (void)addBidderToAccessControlList:(NSString *)bidderName {
    [self performSafeParamsAccess:^{
        [self.rawAccessControlList addObject:[bidderName copy]];
    }];
}

- (void)removeBidderFromAccessControlList:(NSString *)bidderName {
    [self performSafeParamsAccess:^{
        [self.rawAccessControlList removeObject:bidderName];
    }];
}

- (void)clearAccessControlList {
    [self performSafeParamsAccess:^{
        [self.rawAccessControlList removeAllObjects];
    }];
}

- (NSArray<NSString *> *)accessControlList {
    NSArray<NSString *> * __block result = nil;
    [self performSafeParamsAccess:^{
        result = [self.rawAccessControlList allObjects];
    }];
    return result;
}

#pragma mark - User Data

- (void)addUserData:(NSString *)value forKey:(NSString *)key {
    [self performSafeParamsAccess:^{
        NSSet<NSString *> * const oldValues = self.rawUserDataDictionary[key];
        NSSet<NSString *> * const newValues = [(oldValues ?: [[NSSet alloc] init]) setByAddingObject:[value copy]];
        self.rawUserDataDictionary[key] = newValues;
    }];
}

- (void)updateUserData:(NSSet<NSString *> *)value forKey:(NSString *)key {
    NSSet<NSString *> * const newValue = value ? [[NSSet alloc] initWithSet:value copyItems:YES] : nil;
    [self performSafeParamsAccess:^{
        self.rawUserDataDictionary[key] = newValue;
    }];
}

- (void)removeUserDataForKey:(NSString *)key {
    [self performSafeParamsAccess:^{
        self.rawUserDataDictionary[key] = nil;
    }];
}

- (void)clearUserData {
    [self performSafeParamsAccess:^{
        [self.rawUserDataDictionary removeAllObjects];
    }];
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)userDataDictionary {
    NSMutableDictionary<NSString *, NSArray<NSString *> *> * const result = [[NSMutableDictionary alloc] init];
    [self performSafeParamsAccess:^{
        [self.rawUserDataDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                                        NSSet<NSString *> * _Nonnull obj,
                                                                        BOOL * _Nonnull stop)
        {
            result[key] = obj.allObjects;
        }];
    }];
    return result;
}

#pragma mark - Context Data

- (void)addContextData:(NSString *)value forKey:(NSString *)key {
    [self performSafeParamsAccess:^{
        NSSet<NSString *> * const oldValues = self.rawContextDataDictionary[key];
        NSSet<NSString *> * const newValues = [(oldValues ?: [[NSSet alloc] init]) setByAddingObject:[value copy]];
        self.rawContextDataDictionary[key] = newValues;
    }];
}

- (void)updateContextData:(NSSet<NSString *> *)value forKey:(NSString *)key {
    NSSet<NSString *> * const newValue = value ? [[NSSet alloc] initWithSet:value copyItems:YES] : nil;
    [self performSafeParamsAccess:^{
        self.rawContextDataDictionary[key] = newValue;
    }];
}

- (void)removeContextDataForKey:(NSString *)key {
    [self performSafeParamsAccess:^{
        self.rawContextDataDictionary[key] = nil;
    }];
}

- (void)clearContextData {
    [self performSafeParamsAccess:^{
        [self.rawContextDataDictionary removeAllObjects];
    }];
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)contextDataDictionary {
    NSMutableDictionary<NSString *, NSArray<NSString *> *> * const result = [[NSMutableDictionary alloc] init];
    [self performSafeParamsAccess:^{
        [self.rawContextDataDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                                           NSSet<NSString *> * _Nonnull obj,
                                                                           BOOL * _Nonnull stop)
        {
            result[key] = obj.allObjects;
        }];
    }];
    return result;
}

#pragma mark - Internal Methods

- (NSString *)makeCustomParamFromName:(NSString *)name {
    NSString *ret = name;
    
    if (![name hasPrefix:OXATargetingKey_PUB_PROVIDED_PREFIX]) {
        ret = [NSString stringWithFormat:@"%@%@", OXATargetingKey_PUB_PROVIDED_PREFIX, ret];
    }
    
    return ret;
}

@end
