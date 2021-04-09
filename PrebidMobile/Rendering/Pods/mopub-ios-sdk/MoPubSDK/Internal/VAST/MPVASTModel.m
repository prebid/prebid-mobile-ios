//
//  MPVASTModel.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTModel.h"
#import "MPVASTStringUtilities.h"
#import "MPLogging.h"
#import <objc/runtime.h>

id<MPObjectMapper> MPParseArrayOf(id<MPObjectMapper> internalMapper)
{
    return [[MPNSArrayMapper alloc] initWithInternalMapper:internalMapper];
}

id<MPObjectMapper> MPParseURLFromString()
{
    return [[MPNSStringToNSURLMapper alloc] init];
}

id<MPObjectMapper> MPParseNumberFromString(NSNumberFormatterStyle numberStyle)
{
    return [[MPStringToNumberMapper alloc] initWithNumberStyle:numberStyle];
}

id<MPObjectMapper> MPParseTimeIntervalFromDurationString()
{
    return [[MPDurationStringToTimeIntervalMapper alloc] init];
}

id<MPObjectMapper> MPParseClass(Class destinationClass)
{
    return [[MPClassMapper alloc] initWithDestinationClass:destinationClass];
}

#pragma mark -

@implementation MPNSStringToNSURLMapper

- (id _Nullable)mappedObjectFromSourceObject:(id)object {
    if (![object isKindOfClass:self.requiredSourceObjectClass]) {
        return nil;
    }

    // Downcast to known type for safer manipulation.
    NSString *objectAsString = (NSString *)object;

    // No URL to map
    if (objectAsString.length == 0) {
        return nil;
    }

    NSString *URLString = [objectAsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [NSURL URLWithString:URLString];
}

- (Class)requiredSourceObjectClass {
    return [NSString class];
}

@end

#pragma mark -

@implementation MPDurationStringToTimeIntervalMapper

- (id _Nullable)mappedObjectFromSourceObject:(id)object {
    if (![object isKindOfClass:self.requiredSourceObjectClass]) {
        return nil;
    }

    // Downcast to known type for safer manipulation.
    NSString *objectAsString = (NSString *)object;

    // No duration to map
    if (objectAsString.length == 0) {
        return nil;
    }

    // Zero durations are considered invalid. Do not propagate the
    // invalid value downstream.
    NSTimeInterval duration = [MPVASTStringUtilities timeIntervalFromDurationString:objectAsString];
    if (duration <= 0) {
        return nil;
    }

    return @(duration);
}

- (Class)requiredSourceObjectClass {
    return [NSString class];
}

@end

#pragma mark -

@interface MPStringToNumberMapper ()

// Number formatter using the specified style.
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation MPStringToNumberMapper

- (instancetype)init {
    // Disallow `init`. Use `initWithNumberStyle:` instead.
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithNumberStyle:(NSNumberFormatterStyle)numberStyle {
    self = [super init];
    if (self) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = numberStyle;
    }
    return self;
}

- (id _Nullable)mappedObjectFromSourceObject:(id)object {
    if (![object isKindOfClass:self.requiredSourceObjectClass]) {
        return nil;
    }

    return [self.numberFormatter numberFromString:object];
}

- (Class)requiredSourceObjectClass {
    return [NSString class];
}

@end

#pragma mark -

@interface MPClassMapper ()

// Destination class type after mapping.
@property (nonatomic, strong) Class destinationClass;

@end

@implementation MPClassMapper

- (instancetype)init {
    // Disallow `init`. Use `initWithDestinationClass:` instead.
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithDestinationClass:(Class)destinationClass {
    self = [super init];
    if (self) {
        _destinationClass = destinationClass;
    }
    return self;
}

- (id _Nullable)mappedObjectFromSourceObject:(id)object {
    if (![object isKindOfClass:self.requiredSourceObjectClass]) {
        return nil;
    }

    if (![self.destinationClass isSubclassOfClass:[MPVASTModel class]] ||
        ![self.destinationClass instancesRespondToSelector:@selector(initWithDictionary:)]) {
        return nil;
    }

    return [[self.destinationClass alloc] initWithDictionary:object];
}

- (Class)requiredSourceObjectClass {
    return [NSDictionary class];
}

@end

#pragma mark -

@interface MPNSArrayMapper ()

// Mapper used to translate array items.
@property (nonatomic, strong) id<MPObjectMapper> mapper;

@end

@implementation MPNSArrayMapper

- (instancetype)init {
    // Disallow `init`. Use `initWithInternalMapper:` instead.
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithInternalMapper:(id<MPObjectMapper>)mapper {
    self = [super init];
    if (self) {
        _mapper = mapper;
    }
    return self;
}

- (id _Nullable)mappedObjectFromSourceObject:(id)object {
    // If the input isn't a type we recognize, return nil immediately
    if (![object isKindOfClass:self.requiredSourceObjectClass] &&
        ![object isKindOfClass:self.mapper.requiredSourceObjectClass]) {
        return nil;
    }

    // If the input isn't an array, return the mapped version of this object encapsulated in an array.
    if ([object isKindOfClass:self.mapper.requiredSourceObjectClass]) {
        id mappedObject = [self.mapper mappedObjectFromSourceObject:object];

        // If mapping failed, return nil
        if (mappedObject == nil) {
            return nil;
        }

        // If mapping succeeded, return an array with the mapped object
        return @[mappedObject];
    }

    // Otherwise, an array was passed in.
    // Map each object in the original array into a new array and return that array.

    NSArray * originalArray = (NSArray *)object;
    NSMutableArray * mappedArray = [NSMutableArray arrayWithCapacity:originalArray.count];

    [originalArray enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL * stop){
        id mappedObject = [self.mapper mappedObjectFromSourceObject:object];
        if (mappedObject != nil) {
            [mappedArray addObject:mappedObject];
        }
    }];

    return mappedArray.count == 0 ? nil : mappedArray;
}

- (Class)requiredSourceObjectClass {
    return [NSArray class];
}

@end

#pragma mark -

@interface MPVASTModel ()
// Enable property name caching is specified as a class property to facilitate unit testing.
+ (BOOL)enablePropertyNameCaching;
@end

@implementation MPVASTModel

+ (NSDictionary<NSString *, id> *)modelMap {
    // Must be implemented by subclasses.
    return @{};
}

+ (BOOL)enablePropertyNameCaching {
    return YES;
}

- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary {
    // Nothing to parse, don't bother initializing.
    if (dictionary == nil) {
        return nil;
    }

    if (self = [super init]) {
        // Retrieve the model map to parse
        NSDictionary<NSString *, id> *modelMap = [[self class] modelMap];

        // Process all of the entries in the model map.
        [modelMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull modelMapValue, BOOL * _Nonnull stop) {
            // Validate that the key path is valid for this object. Otherwise, ignore this key path entry.
            if ([self hasPropertyNamed:key] == NO) {
                return;
            }

            // Value is a key path.
            if ([modelMapValue isKindOfClass:[NSString class]]) {
                // The simple case: grab the value corresponding to the given key path and
                // assign it to the property.
                id value = [dictionary valueForKeyPath:modelMapValue];
                if (value) {
                    [self setValue:value forKey:key];
                }
            }
            // Value is a constrained array, where the first item is the key path and the
            // second item conforms to the `MPObjectMapper` protocol.
            else if ([modelMapValue isKindOfClass:[NSArray class]] && [modelMapValue count] == 2) {
                NSString *dictionaryKeyPath = modelMapValue[0];
                id<MPObjectMapper> mapper = modelMapValue[1];

                if ([mapper conformsToProtocol:@protocol(MPObjectMapper)]) {
                    id sourceObject = [dictionary valueForKeyPath:dictionaryKeyPath];
                    if (sourceObject) {
                        id model = [mapper mappedObjectFromSourceObject:sourceObject];
                        if (model) {
                            [self setValue:model forKey:key];
                        }
                    }
                }
            }
            // Unsupported value
            else {
                MPLogInfo(@"Could not populate %@ of class %@ because its mapper is invalid.", key, NSStringFromClass([self class]));
            }
        }]; // end enumerateKeysAndObjectsUsingBlock:
    }
    return self;
}

- (id _Nullable)generateModelFromDictionaryValue:(id _Nullable)value modelProvider:(id(^)(id))provider {
    if (value && [value isKindOfClass:[NSArray class]] && [value count] > 0) {
        return provider(value[0]);
    } else if (value && [value isKindOfClass:[NSDictionary class]]) {
        return provider(value);
    } else {
        return nil;
    }
}

- (NSArray *)generateModelsFromDictionaryValue:(id _Nullable)value modelProvider:(id(^)(id))provider {
    NSMutableArray *models = [NSMutableArray array];

    if (value && [value isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dictionary in value) {
            id model = provider(dictionary);
            if (model) {
                [models addObject:model];
            }
        }
    } else if (value && [value isKindOfClass:[NSDictionary class]]) {
        id model = provider(value);
        if (model) {
            [models addObject:model];
        }
    }

    return [models copy];
}

#pragma mark - Internal

/**
 Queries if the class has a property with the specified key path.
 @param name The case-sensitive key path to the property.
 @return `YES` if it exists; otherwise `NO`.
 */
- (BOOL)hasPropertyNamed:(NSString *)name {
    // This method uses the objc runtime API to check whether the current model class has a given
    // property. After we grab the set of properties for a given class, we cache it for efficiency.

    static NSMutableDictionary<NSString *, NSMutableSet *> *propertyNamesForClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertyNamesForClass = [NSMutableDictionary dictionary];
    });

    NSString *className = NSStringFromClass([self class]);
    NSMutableSet *propertyNames = nil;

    // Since `MPVastModel` objects are parsed on a background thread,
    // synchronize access to `propertyNamesForClass`.
    @synchronized(propertyNamesForClass) {
        propertyNames = propertyNamesForClass[className];

        if ([MPVASTModel enablePropertyNameCaching] == NO || propertyNames == nil) {
            unsigned int propertyCount;
            objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
            propertyNames = [NSMutableSet setWithCapacity:propertyCount];
            for (unsigned int i = 0; i < propertyCount; i++) {
                objc_property_t property = properties[i];
                [propertyNames addObject:[NSString stringWithUTF8String:property_getName(property)]];
            }
            propertyNamesForClass[className] = propertyNames;
            free(properties);
        }
    }

    return [propertyNames containsObject:name];
}

- (NSString *)description {
    NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"%@:", NSStringFromClass([self class])];

    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
        [descriptionString appendFormat:@"\n\t%s = %s", propertyName.UTF8String, [[self valueForKey:propertyName] description].UTF8String];
    }

    free(properties);
    return descriptionString;
}

@end
