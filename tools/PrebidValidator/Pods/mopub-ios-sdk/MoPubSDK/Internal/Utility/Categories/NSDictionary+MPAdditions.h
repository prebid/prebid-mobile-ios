//
//  NSDictionary+MPAdditions.h
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MPAdditions)

- (NSInteger)mp_integerForKey:(id)key;
- (NSInteger)mp_integerForKey:(id)key defaultValue:(NSInteger)defaultVal;
- (double)mp_doubleForKey:(id)key;
- (double)mp_doubleForKey:(id)key defaultValue:(double)defaultVal;
- (NSString *)mp_stringForKey:(id)key;
- (NSString *)mp_stringForKey:(id)key defaultValue:(NSString *)defaultVal;
- (BOOL)mp_boolForKey:(id)key;
- (BOOL)mp_boolForKey:(id)key defaultValue:(BOOL)defaultVal;
- (float)mp_floatForKey:(id)key;
- (float)mp_floatForKey:(id)key defaultValue:(float)defaultVal;

@end
