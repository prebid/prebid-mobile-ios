//
//  AFKeyValue.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 27/01/17.
//  Copyright © 2017 adform. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AFKeyValue(aKey, aValue) [[AFKeyValue alloc] initWithKey:aKey value:aValue]

/**
 A key value pair that can be set to ad views.
 */
@interface AFKeyValue : NSObject

/// A key.
@property (nonnull, nonatomic, strong) NSString *key;

/// A value.
@property (nonnull, nonatomic, strong) NSString *value;

/**
 Designated initializer.
 
 For convenience you should use 'AFKeyValue(key, value)' macro.
 */
- (nonnull instancetype)initWithKey:(nonnull NSString *)key value:(nonnull NSString *)value;

/**
 Creates a key value from dictionary representation.
 
 You can use this initializer to create key value pair with dictionary containing
 one value.
 
 Example:
    \code
        AFKeyValue *keyValue = [[AFKeyValue alloc] initWithDictionary: @{@"age", @"21"}];
    \endcode
 This code creates a key value object where key is "age" and value is "21".
 */
- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary<NSString *, NSString *> *)keyValue;

@end

/**
 Converts a NSDictionary containing key value data to an NSArray containing AFKeyValue 
 objects.
 
 @param dictionary A dictionary you want to convert.
 @return An array containing AFKeyValue objects created from dictionary values.
 */
extern NSArray<AFKeyValue *> * _Nonnull AFKeyValuesFromNSDictionary(NSDictionary<NSString *, NSString *> * _Nonnull dictionary);
