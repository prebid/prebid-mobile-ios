//
//  OXADFPRequest.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXADFPRequest.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "OXAInvocationHelper.h"


static NSNumber *classesCheckResult = nil;

@interface OXADFPRequest ()
@property (nonatomic, strong, readonly) DFPRequest *request;
@end


@implementation OXADFPRequest

- (instancetype)init {
    return (self = [self initWithDFPRequest:[[DFPRequest alloc] init]]);
}

- (instancetype)initWithDFPRequest:(DFPRequest *)dfpRequest {
    if (!(self = [super init])) {
        return nil;
    }
    _request = dfpRequest;
    return self;
}

// MARK: - Public (own) properties

+ (BOOL)classesFound {
    if (classesCheckResult != nil) {
        return classesCheckResult.boolValue;
    }
    const BOOL classesFound = [self findClasses];
    classesCheckResult = @(classesFound);
    return classesFound;
}

- (NSObject *)boxedRequest {
    return self.request;
}

// MARK: - Public (Boxed) Properties

- (void)setCustomTargeting:(NSDictionary *)customTargeting {
    [OXAInvocationHelper invokeVoidSelector:@selector(setCustomTargeting:)
                                 withObject:customTargeting
                                   onTarget:self.request
                                onException:nil];
}

- (NSDictionary *)customTargeting {
    NSDictionary *result = nil;
    [OXAInvocationHelper invokeClassResultSelector:@selector(customTargeting)
                                          onTarget:self.request
                                       resultClass:[NSDictionary class]
                                         outResult:&result
                                       onException:nil];
    return result;
}

// MARK: - Public methods

// MARK: - Private Helpers

+ (BOOL)findClasses {
    BOOL result = NO;
    @try {
        if (!NSClassFromString(@"DFPRequest")) {
            return NO;
        }
        Class const testClass = [DFPRequest class];
        SEL selectors[] = {
            @selector(customTargeting),
            @selector(setCustomTargeting:),
        };
        const size_t selectorsCount = sizeof(selectors) / sizeof(selectors[0]);
        for(size_t i = 0; i < selectorsCount; i++) {
            if (![testClass instancesRespondToSelector:selectors[i]]) {
                return NO;
            }
        }
        result = YES;
    }
    @catch(id anException) {
        result = NO;
    };
    return result;
}

@end
