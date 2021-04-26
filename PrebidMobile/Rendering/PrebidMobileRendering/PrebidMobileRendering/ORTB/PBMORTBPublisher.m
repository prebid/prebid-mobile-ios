//
//  PBMORTBPublisher.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBPublisher.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBPublisher

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

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.publisherID;
    ret[@"name"] = self.name;
    ret[@"domain"] = self.domain;
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
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
