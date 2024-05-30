//
//  PBMORTBRendererConfig.m..m
//  BitByteData-iOS11.0
//
//  Created by Richard Dépierre on 17/05/2024.
//

#import "PBMORTBRendererConfig.h"

@implementation PBMORTBRendererConfig

- (instancetype)initWithName:(NSString *)name version:(NSString *)version data:(NSDictionary<NSString *, id> *)data {
    self = [super init];
    if (self) {
        _name = [name copy];
        _version = [version copy];
        _data = [data copy];
    }
    return self;
}

@end
