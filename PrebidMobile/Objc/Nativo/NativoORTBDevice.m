
#import "NativoORTBDevice.h"
#import "PBMORTBAbstract+Protected.h"

@implementation NativoORTBDevice

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    self = [super initWithJsonDictionary:jsonDictionary];
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = ((PBMMutableJsonDictionary*)[super toJsonDictionary]);
    if (self.ip) {
        ret[@"ip"] = self.ip;
    }
    return ret;
}

@end

