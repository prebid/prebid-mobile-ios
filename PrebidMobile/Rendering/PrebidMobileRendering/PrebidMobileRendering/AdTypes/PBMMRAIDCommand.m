//
//  PBMMRAIDCommand.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMMRAIDCommand.h"
#import "PBMError.h"
#import "NSString+PBMExtensions.h"

#pragma mark - Private Extension

@interface PBMMRAIDCommand ()

@property (nonatomic, copy, nonnull) PBMMRAIDAction command;
@property (nonatomic, strong, nonnull) NSArray<NSString *> *arguments;

@end

#pragma mark - Implementation

@implementation PBMMRAIDCommand

- (nullable instancetype)initWithURL:(nonnull NSString *)url error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    
    // Prepare @command
    
    if (!url) {
        NSString *message = [NSString stringWithFormat:@"URL is nil"];
        [PBMError createError:error description:message];
        return nil;
    }
    
    NSString *mraidPath = [url PBMsubstringFromString:[PBMMRAIDConstants mraidURLScheme]];
    if (!mraidPath) {
        NSString *message = [NSString stringWithFormat:@"URL does not contain MRAID scheme: %@", url];
        [PBMError createError:error description:message];
        return nil;
    }
    
    NSMutableArray<NSString *> *components = [[mraidPath componentsSeparatedByString:@"/"] mutableCopy];
    NSString *commandString = [[components firstObject] lowercaseString];
    if (!commandString || [commandString isEqualToString:@""]) {
        NSString *message = [NSString stringWithFormat:@"Command not found in MRAID url: %@", url];
        [PBMError createError:error description:message];
        return nil;
    }
    
    NSString *parsedCommandString = nil;
    for (NSString *constant in [PBMMRAIDConstants allCases]) {
        if ([[constant lowercaseString] isEqualToString:commandString]) {
            parsedCommandString = constant;
            break;
        }
    }
    
    if (!parsedCommandString) {
        NSString *message = [NSString stringWithFormat:@"Unrecognized MRAID command %@", commandString];
        [PBMError createError:error description:message];
        return nil;
    }
    
    // Prepare @arguments
    
    [components removeObjectAtIndex:0];
    NSMutableArray *parsedArguments = [NSMutableArray array];

    for (NSString *component in components) {
        NSString *componentWithPercentEncodingResolved = [component stringByRemovingPercentEncoding];
        if (componentWithPercentEncodingResolved) {
            [parsedArguments addObject:componentWithPercentEncodingResolved];
        }
        else {
            NSString *message = [NSString stringWithFormat:@"Unable to parse MRAID command argument: %@ on url: %@", component, url];
            [PBMError createError:error description:message];
            return nil;
        }
    }
    
    // Init the object
    
    self = [super init];
    if (self) {
        self.command = parsedCommandString;
        self.arguments = parsedArguments;
    }
    
    return self;
}

@end
