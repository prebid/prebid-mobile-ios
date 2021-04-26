//
//  PBMInvocationHelper.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSExceptionName const PBMInvalidInvocationResultTypeException;
extern NSExceptionName const PBMVoidSelectorReturnedValueException;

@interface PBMInvocationHelper : NSObject

- (instancetype)init NS_UNAVAILABLE;

// MARK: - Universal methods

+ (void)invokeSelector:(SEL)selector
            withObject:(nullable id)object
              onTarget:(NSObject *)target
   customizeInvocation:(void (^ _Nullable)(NSMethodSignature *, NSInvocation *))invocationCustomizationBlock
              onResult:(void (^ _Nullable)(id _Nullable))resultHandlerBlock                // no result -- only if result if nil
           onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock; // no exception -- selector not found; has void exception

+ (void)invokeSelector:(SEL)selector
            withObject:(nullable id)object
              onTarget:(NSObject *)target
              onResult:(void (^ _Nullable)(id _Nullable))resultHandlerBlock                // no result -- only if result if nil
           onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock; // no exception -- selector not found; has void exception

// MARK: - Void methods

+ (void)invokeVoidSelector:(SEL)selector
                withObject:(nullable id)object
               otherObject:(nullable id)otherObject
                  onTarget:(NSObject *)target
               onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock; // no exception -- selector not found

+ (void)invokeVoidSelector:(SEL)selector
                withObject:(nullable id)object
                  onTarget:(NSObject *)target
               onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock; // no exception -- selector not found

+ (void)invokeVoidSelector:(SEL)selector
                  onTarget:(NSObject *)target
               onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock; // no exception -- selector not found

+ (void)invokeVoidSelector:(SEL)selector
              withArgument:(void *)firstArgument
                  onTarget:(NSObject *)target
               onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock; // no exception -- selector not found

// MARK: - C-type-result methods

+ (void)invokeCResultSelector:(SEL)selector
                   withObject:(nullable id)object
                     onTarget:(NSObject *)target
                   resultType:(const char *)resultType
                     onResult:(void (^)(NSValue * _Nullable))resultHandlerBlock
                  onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock;

+ (void)invokeCResultSelector:(SEL)selector
                     onTarget:(NSObject *)target
                   resultType:(const char *)resultType
                     onResult:(void (^)(NSValue * _Nullable))resultHandlerBlock
                  onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock;

// MARK: - Class-type-result methods

+ (void)invokeClassResultSelector:(SEL)selector
                       withObject:(nullable id)object
                         onTarget:(NSObject *)target
                      resultClass:(Class)resultClass
                        outResult:(NSObject * __strong _Nullable * _Nonnull)resultBuffer
                      onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock;

+ (void)invokeClassResultSelector:(SEL)selector
                         onTarget:(NSObject *)target
                      resultClass:(Class)resultClass
                        outResult:(NSObject * __strong _Nullable * _Nonnull)resultBuffer
                      onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock;

// MARK: - Protocol-type-result methods

+ (void)invokeProtocolResultSelector:(SEL)selector
                          withObject:(nullable id)object
                            onTarget:(NSObject *)target
                      resultProtocol:(Protocol *)resultProtocol
                           outResult:(id __strong _Nullable * _Nonnull)resultBuffer
                         onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock;

+ (void)invokeProtocolResultSelector:(SEL)selector
                            onTarget:(NSObject *)target
                      resultProtocol:(Protocol *)resultProtocol
                           outResult:(id __strong _Nullable * _Nonnull)resultBuffer
                         onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock;

@end

NS_ASSUME_NONNULL_END
