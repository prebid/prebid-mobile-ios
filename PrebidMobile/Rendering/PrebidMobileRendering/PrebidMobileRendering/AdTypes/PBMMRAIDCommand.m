/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
