//
//  PBMURLComponents.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMURLComponents.h"
#import "NSString+PBMExtensions.h"

#pragma mark - Private Extension

@interface PBMURLComponents()

@property (nonatomic, strong) NSURLComponents * nsUrlComponents;

@end

#pragma mark - Implementation

@implementation PBMURLComponents

#pragma mark - Public

-(instancetype)initWithUrl:(NSString *)url paramsDict:(NSDictionary<NSString *,NSString *> *)paramsDict {
    self = [super init];

    if (!self) {
        return nil;
    }

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url];
    if (!urlComponents || !paramsDict) {
        return nil;
    }

    //Convert existing query items to a dict
    NSMutableArray *queryItems = urlComponents.queryItems ? [NSMutableArray arrayWithArray:urlComponents.queryItems] : [NSMutableArray array];

    //Add URLQueryItems from paramsDict. This may result in some keys appearing twice
    NSArray * sortedKeys = [[paramsDict allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys) {
        [queryItems addObject: [NSURLQueryItem queryItemWithName:key value:paramsDict[key]]];
    }

    //Remove dupes.
    //Items added later have higher precedence, so we reverse the list first
    queryItems = [[[queryItems reverseObjectEnumerator] allObjects] mutableCopy];

    //If the accumulator array contains an item that has the same name,
    // ignore the current item we are examining
    //Otherwise, append the item we are examining to the accumulator.
    NSMutableArray *filteredItems = [NSMutableArray array];
    for (NSURLQueryItem *item in queryItems) {
        BOOL contains = NO;
        for (NSURLQueryItem *filteredItem in filteredItems) {
            if ([filteredItem.name isEqualToString:item.name]) {
                contains = YES;
                break;
            }
        }
        if (!contains){
            [filteredItems addObject:item];
        }
    }
        
    filteredItems = [[[filteredItems reverseObjectEnumerator] allObjects] mutableCopy];
    urlComponents.queryItems = filteredItems;
    self.nsUrlComponents = urlComponents;

    return self;
}

-(NSString *)fullURL {
    return self.nsUrlComponents.string ?: @"";
}

-(NSString *)urlString {
    NSString *ret = [[self.nsUrlComponents string] PBMsubstringToString:@"?"];
    if (!ret) {
        ret = [self.nsUrlComponents string];
    }
    return ret ?: @"";
}

-(NSString *)argumentsString {
    NSString *ret = [self.nsUrlComponents percentEncodedQuery];
    return  ret ?: @"";
}

@end
