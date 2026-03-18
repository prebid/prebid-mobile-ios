    
#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

@class AdUnitConfig;

NS_ASSUME_NONNULL_BEGIN

@interface NativoParameterBuilder : NSObject <PBMParameterBuilder>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(AdUnitConfig *)adConfiguration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
