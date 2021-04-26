//
//  PBMInvocationHelper.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMInvocationHelper.h"

NSExceptionName const PBMInvalidInvocationResultTypeException = @"PBMInvalidInvocationResultTypeException";
NSExceptionName const PBMVoidSelectorReturnedValueException = @"PBMVoidSelectorReturnedValueException";

@implementation PBMInvocationHelper

// MARK: - Universal methods

+ (void)invokeSelector:(SEL)selector
            withObject:(nullable id)object
              onTarget:(NSObject *)target
   customizeInvocation:(void (^ _Nullable)(NSMethodSignature *, NSInvocation *))invocationCustomizationBlock
              onResult:(void (^ _Nullable)(id _Nullable))resultHandlerBlock
           onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock
{
    void (^ const reportFailure)(NSException * _Nullable) = ^(NSException *ex) {
        if (exceptionHandlerBlock) {
            exceptionHandlerBlock(ex);
        }
    };
    NSMethodSignature * const signature = [target methodSignatureForSelector:selector];
    if (!signature) {
        reportFailure(nil);
        return;
    }
    NSInvocation * const invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    if (signature.numberOfArguments > 2 && object) {
        id __strong firstArg = object;
        [invocation setArgument:&firstArg atIndex:2];
    }
    NSInvocationOperation * const operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    if (!operation) { // selector not found on target
        reportFailure(nil);
        return;
    }
    if (invocationCustomizationBlock) {
        invocationCustomizationBlock(signature, invocation);
    }
    @try {
        [operation start];
    }
    @catch (NSException *exception) {
        reportFailure(exception);
        return;
    }
    if (!strcmp(signature.methodReturnType, @encode(void))) {
        // no return value
    }
    id result = nil;
    @try {
        result = operation.result;
    }
    @catch (NSException *exception) {
        reportFailure(exception);
        return;
    }
    if (resultHandlerBlock) {
        resultHandlerBlock(result);
    }
}

+ (void)invokeSelector:(SEL)selector
            withObject:(nullable id)object
              onTarget:(NSObject *)target
              onResult:(void (^ _Nullable)(id _Nullable))resultHandlerBlock
           onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeSelector:selector
              withObject:object
                onTarget:target
     customizeInvocation:nil
                onResult:resultHandlerBlock
             onException:exceptionHandlerBlock];
}

// MARK: - Void methods

+ (void)invokeVoidSelector:(SEL)selector
                withObject:(id)object
               otherObject:(id)otherObject
                  onTarget:(NSObject *)target
               onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    __block id secondArgument = otherObject;
    [self invokeSelector:selector
              withObject:object
                onTarget:target
     customizeInvocation:^(NSMethodSignature *methodSignature, NSInvocation *invocation) {
        if (methodSignature.numberOfArguments > 3) {
            [invocation setArgument:&secondArgument atIndex:3];
        }
    }
                onResult:[self buildResultHandlerForVoidSelectors:exceptionHandlerBlock]
             onException:[self wrapExceptionHandlerForVoidResult:exceptionHandlerBlock]];
}

+ (void)invokeVoidSelector:(SEL)selector
                withObject:(id)object
                  onTarget:(NSObject *)target
               onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeSelector:selector
              withObject:object
                onTarget:target
                onResult:[self buildResultHandlerForVoidSelectors:exceptionHandlerBlock]
             onException:[self wrapExceptionHandlerForVoidResult:exceptionHandlerBlock]];
}

+ (void)invokeVoidSelector:(SEL)selector
                  onTarget:(NSObject *)target
               onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeVoidSelector:selector
                  withObject:nil
                    onTarget:target
                 onException:exceptionHandlerBlock];
}

+ (void)invokeVoidSelector:(SEL)selector
              withArgument:(void *)firstArgument
                  onTarget:(NSObject *)target
               onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeSelector:selector
              withObject:nil
                onTarget:target
     customizeInvocation:^(NSMethodSignature *methodSignature, NSInvocation *invocation) {
        if (methodSignature.numberOfArguments > 2) {
            [invocation setArgument:firstArgument atIndex:2];
        }
    }
                onResult:[self buildResultHandlerForVoidSelectors:exceptionHandlerBlock]
             onException:[self wrapExceptionHandlerForVoidResult:exceptionHandlerBlock]];
}

+ (void (^ _Nullable)(id _Nullable))buildResultHandlerForVoidSelectors:(void (^)(NSException * _Nullable))exceptionHandlerBlock {
    return ^(id result) {
        if (exceptionHandlerBlock) {
            NSString *msg = [NSString stringWithFormat:@"Unexpectedly received result (%@ of type %@) for void-result selector",
                             result, [result class]];
            exceptionHandlerBlock([NSException exceptionWithName:PBMVoidSelectorReturnedValueException
                                                          reason:msg
                                                        userInfo:nil]);
        }
    };
}

+ (void (^)(NSException * _Nullable))wrapExceptionHandlerForVoidResult:(void (^)(NSException * _Nullable))exceptionHandlerBlock {
    return ^(NSException *exception) {
        if ([exception.name isEqualToString:NSInvocationOperationVoidResultException]) {
            return; // ok -- void result expected
        }
        if (exceptionHandlerBlock) {
            exceptionHandlerBlock(exception);
        }
    };
}

// MARK: - C-type-result methods

+ (void)invokeCResultSelector:(SEL)selector
                   withObject:(id)object
                     onTarget:(NSObject *)target
                   resultType:(const char *)resultType
                     onResult:(void (^)(NSValue * _Nullable))resultHandlerBlock
                  onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeSelector:selector
              withObject:object
                onTarget:target
                onResult:^(id _Nullable result) {
        if (!result) {
            if (resultHandlerBlock) {
                resultHandlerBlock(result);
            }
            return;
        }
        if (![result isKindOfClass:[NSValue class]]) {
            if (exceptionHandlerBlock) {
                NSString *resultClass = NSStringFromClass([result class]);
                NSString *msg = [NSString stringWithFormat:@"Object type '%@' does not match expected '%s' value type",
                                 resultClass, resultType];
                exceptionHandlerBlock([NSException exceptionWithName:PBMInvalidInvocationResultTypeException
                                                              reason:msg
                                                            userInfo:nil]);
            }
            return;
        }
        NSValue * const valueResult = (NSValue *)result;
        if (strcmp(valueResult.objCType, resultType)) {
            if (exceptionHandlerBlock) {
                NSString *msg = [NSString stringWithFormat:@"Value type '%s' does not match expected '%s' value type",
                                 valueResult.objCType, resultType];
                exceptionHandlerBlock([NSException exceptionWithName:PBMInvalidInvocationResultTypeException
                                                              reason:msg
                                                            userInfo:nil]);
            }
            return;
        }
        if (resultHandlerBlock) {
            resultHandlerBlock(valueResult);
        }
    }
             onException:exceptionHandlerBlock];
}

+ (void)invokeCResultSelector:(SEL)selector
                     onTarget:(NSObject *)target
                   resultType:(const char *)resultType
                     onResult:(void (^)(NSValue * _Nullable))resultHandlerBlock
                  onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeCResultSelector:selector
                     withObject:nil
                       onTarget:target
                     resultType:resultType
                       onResult:resultHandlerBlock
                    onException:exceptionHandlerBlock];
}

// MARK: - Class-type-result methods

+ (void)invokeClassResultSelector:(SEL)selector
                       withObject:(nullable id)object
                         onTarget:(NSObject *)target
                      resultClass:(Class)resultClass
                        outResult:(NSObject * __strong _Nullable * _Nonnull)resultBuffer
                      onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeSelector:selector
              withObject:object
                onTarget:target
                onResult:^(id _Nullable result) {
        *resultBuffer = nil;
        if (!result) {
            return;
        }
        if (![result isKindOfClass:resultClass]) {
            if (exceptionHandlerBlock) {
                NSString *returnedClass = NSStringFromClass([result class]);
                NSString *msg = [NSString stringWithFormat:@"Result class '%@' does not match expected class '%@'",
                                 returnedClass, NSStringFromClass(resultClass)];
                exceptionHandlerBlock([NSException exceptionWithName:PBMInvalidInvocationResultTypeException
                                                              reason:msg
                                                            userInfo:nil]);
            }
            return;
        }
        *resultBuffer = result;
    }
             onException:exceptionHandlerBlock];
}

+ (void)invokeClassResultSelector:(SEL)selector
                         onTarget:(NSObject *)target
                      resultClass:(Class)resultClass
                        outResult:(NSObject * __strong _Nullable * _Nonnull)resultBuffer
                      onException:(void (^)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeClassResultSelector:selector
                         withObject:nil
                           onTarget:target
                        resultClass:resultClass
                          outResult:resultBuffer
                        onException:exceptionHandlerBlock];
}

// MARK: - Protocol-type-result methods

+ (void)invokeProtocolResultSelector:(SEL)selector
                          withObject:(nullable id)object
                            onTarget:(NSObject *)target
                      resultProtocol:(Protocol *)resultProtocol
                           outResult:(id __strong _Nullable * _Nonnull)resultBuffer
                         onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeSelector:selector
              withObject:object
                onTarget:target
                onResult:^(id _Nullable result) {
        *resultBuffer = nil;
        if (!result) {
            return;
        }
        if (![result conformsToProtocol:resultProtocol]) {
            if (exceptionHandlerBlock) {
                NSString *returnedClass = NSStringFromClass([result class]);
                NSString *msg = [NSString stringWithFormat:@"Result class '%@' does not conform to expected protocol '%@'",
                                 returnedClass, NSStringFromProtocol(resultProtocol)];
                exceptionHandlerBlock([NSException exceptionWithName:PBMInvalidInvocationResultTypeException
                                                              reason:msg
                                                            userInfo:nil]);
            }
            return;
        }
        *resultBuffer = result;
    }
             onException:exceptionHandlerBlock];
}

+ (void)invokeProtocolResultSelector:(SEL)selector
                            onTarget:(NSObject *)target
                      resultProtocol:(Protocol *)resultProtocol
                           outResult:(id __strong _Nullable * _Nonnull)resultBuffer
                         onException:(void (^ _Nullable)(NSException * _Nullable))exceptionHandlerBlock
{
    [self invokeProtocolResultSelector:selector
                            withObject:nil
                              onTarget:target
                        resultProtocol:resultProtocol
                             outResult:resultBuffer
                           onException:exceptionHandlerBlock];
}

@end
