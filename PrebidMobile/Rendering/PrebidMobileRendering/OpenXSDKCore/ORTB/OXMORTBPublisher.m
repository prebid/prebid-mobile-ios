//
//  OXMORTBPublisher.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBPublisher.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBPublisher

- (nonnull instancetype )init {
    if (!(self = [super init])) {
        return nil;
    }
    _cat = @[];
    
    return self;
}

- (void)setCat:(NSArray<NSString *> *)cat {
    _cat = cat ? [NSArray arrayWithArray:cat] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"id"] = self.publisherID;
    ret[@"name"] = self.name;
    ret[@"domain"] = self.domain;
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _publisherID = jsonDictionary[@"id"];
    _name = jsonDictionary[@"name"];
    _domain = jsonDictionary[@"domain"];
    _cat = jsonDictionary[@"cat"];
    
    return self;
}

@end
