//
//  JSLibrary.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMJSLibrary.h"

@implementation OXMJSLibrary

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.version = dict[@"version"];
        self.downloadURL = [NSURL URLWithString:dict[@"download_url"]];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.version = [coder decodeObjectForKey:@"version"];
        self.downloadURL = [coder decodeObjectOfClass:[NSURL class] forKey:@"downloadURL"];
        self.contentsString = [coder decodeObjectOfClass:[NSString class] forKey:@"contentsString"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.version forKey:@"version"];
    [coder encodeObject:self.downloadURL forKey:@"downloadURL"];
    [coder encodeObject:self.contentsString forKey:@"contentsString"];
}

@end
