//
//  MPVASTWrapper.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTWrapper.h"
#import "MPVASTCreative.h"

@interface MPVASTWrapper ()

// This property is listed here as readwrite to allow `MPVASTManager` to update
// this value in its own private category.
@property (nonatomic, nullable, strong, readwrite) MPVASTResponse *wrappedVASTResponse;

@end

@implementation MPVASTWrapper

#pragma mark - MPVASTModel

- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        // Custom parsing to generate the array of extensions found in the wrapper.
        // In the event of a malformed `Extensions` element, no extensions will be parsed.
        id extensionsElement = dictionary[@"Extensions"];
        if (extensionsElement != nil && [extensionsElement isKindOfClass:[NSDictionary class]]) {
            // Map the elements of Extensions.Extension into an array of dictionaries.
            NSDictionary *extensionsElementDictionary = (NSDictionary *)extensionsElement;
            NSArray<NSDictionary *> *extensions = [self generateModelsFromDictionaryValue:extensionsElementDictionary[@"Extension"]
                                                                            modelProvider:^id(NSDictionary *dictionary) {
                return dictionary;
            }];

            _extensions = extensions.count > 0 ? extensions : nil;
        } // End if

        // Extract the `AdVerifications` node from the extensions if it exists
        [_extensions enumerateObjectsUsingBlock:^(NSDictionary *extension, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *type = extension[@"type"];
            NSDictionary *adVerficationsDictionary = extension[@"AdVerifications"];
            if (adVerficationsDictionary != nil && [type isEqualToString:@"AdVerifications"]) {
                _adVerifications = [[MPVASTAdVerifications alloc] initWithDictionary:adVerficationsDictionary];
                *stop = YES;
            }
        }];
    }
    return self;
}

+ (NSDictionary<NSString *, id> *)modelMap {
    return @{@"adVerifications": @[@"AdVerifications", MPParseClass([MPVASTAdVerifications class])],
             @"creatives":       @[@"Creatives.Creative", MPParseArrayOf(MPParseClass([MPVASTCreative class]))],
             @"errorURLs":       @[@"Error.text", MPParseArrayOf(MPParseURLFromString())],
             @"impressionURLs":  @[@"Impression.text", MPParseArrayOf(MPParseURLFromString())],
             @"VASTAdTagURI":    @[@"VASTAdTagURI.text", MPParseURLFromString()]};
}

@end
