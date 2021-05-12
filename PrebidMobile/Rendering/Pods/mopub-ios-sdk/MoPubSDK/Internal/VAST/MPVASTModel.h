//
//  MPVASTModel.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol describing how to parse the source object.
 */
@protocol MPObjectMapper <NSObject>

/**
 Parses the source object of class `requiredSourceObjectClass` into the expected destination object.
 @param object Source object must be of class `requiredSourceObjectClass`.
 @returns The parsed destination object, or `nil` if there was a problem parsing or if `object` class is not `requiredSourceObjectClass`.
 */
- (id _Nullable)mappedObjectFromSourceObject:(id)object;

/**
 The expected class of the source object.
 */
- (Class)requiredSourceObjectClass;

@end

#pragma mark - Global Convenience Methods

id<MPObjectMapper> MPParseArrayOf(id<MPObjectMapper> internalMapper);
id<MPObjectMapper> MPParseURLFromString(void);
id<MPObjectMapper> MPParseNumberFromString(NSNumberFormatterStyle numberStyle);
id<MPObjectMapper> MPParseTimeIntervalFromDurationString(void);
id<MPObjectMapper> MPParseClass(Class destinationClass);

#pragma mark -

@interface MPNSStringToNSURLMapper : NSObject <MPObjectMapper>
@end

#pragma mark -

@interface MPDurationStringToTimeIntervalMapper : NSObject <MPObjectMapper>
// Duration strings must be of the format `HH:MM:SS.mmm`. Zero durations are considered invalid.
@end

#pragma mark -

@interface MPStringToNumberMapper : NSObject <MPObjectMapper>

/**
Initializes the mappter with the expected number format.
@param numberStyle Number format.
@return An instance of the number mapper.
*/
- (instancetype)initWithNumberStyle:(NSNumberFormatterStyle)numberStyle;

// Use the designated initializer instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark -

@interface MPClassMapper : NSObject <MPObjectMapper>

/**
 Initializes the mapper with the destination class type.
 @param destinationClass A subclass of `MPVASTModel` that is the expected destination class type.
 @return An instance of the class mapper.
 */
- (instancetype)initWithDestinationClass:(Class)destinationClass NS_DESIGNATED_INITIALIZER;

// Use the designated initializer instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark -

@interface MPNSArrayMapper : NSObject <MPObjectMapper>

/**
 Initializes the array mapper with the `MPObjectMapper` to use for each array item.
 @param mapper Required array item mapping object.
 @return An instance of the array mapper.
 */
- (instancetype)initWithInternalMapper:(id<MPObjectMapper>)mapper NS_DESIGNATED_INITIALIZER;

// Use the designated initializer instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark -

/**
 Base class for the VAST creative object model.
 */
@interface MPVASTModel : NSObject

/**
 The model map provides information to `initWithDictionary:` on how to populate the model's properties. Each key in `modelMap`
 refers to the case-sensitive key path to the property.
 The value for a key can either be a `NSString *` representation of the key path in the VAST XML, or a `NSArray *` of
 exactly 2 elements, representing the key path in the VAST XML as the first item and a `id<MPObjectMapper>` for
 the second item.
 In the event that there is no mapping available, return an empty dictionary.
 */
+ (NSDictionary<NSString *, id> *)modelMap;

/**
 Initializes the model with a dictionary representation of the VAST element.
 @param dictionary Optional dictionary repesentation of the VAST element.
 @return VAST model instance if it's possible to parse; otherwise `nil`.
 */
- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary NS_DESIGNATED_INITIALIZER;

/**
 Helper method designed to be used within `initWithDictionary:` that provides custom model mapping more complex than
 what is provided by `MPNSStringToNSURLMapper`, `MPDurationStringToTimeIntervalMapper`, `MPStringToNumberMapper`,
 `MPClassMapper`, and `MPNSArrayMapper`.
 @param value Value to be parsed. The value must be of kind `NSArray` or `NSDictionary`, otherwise it will not parse.
 @param provider Block that provides the custom object model mapping.
 @return The parsed object if successful; otherwise `nil`.
 */
- (id _Nullable)generateModelFromDictionaryValue:(id _Nullable)value modelProvider:(id(^)(id))provider;

/**
 Helper method designed to be used within `initWithDictionary:` that provides custom model mapping more complex than
 what is provided by `MPNSStringToNSURLMapper`, `MPDurationStringToTimeIntervalMapper`, `MPStringToNumberMapper`,
 `MPClassMapper`, and `MPNSArrayMapper`.
 @param value Value to be parsed.
 @param provider Block that provides the custom object model mapping.
 @return An array of the mapped objects if successful; otherwise an empty array.
 */
- (NSArray *)generateModelsFromDictionaryValue:(id _Nullable)value modelProvider:(id(^)(id))provider;

#pragma mark - Unavailable

// Use the designated initializer instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
