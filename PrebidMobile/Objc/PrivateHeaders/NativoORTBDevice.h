
#import <Foundation/Foundation.h>
#import "PBMORTBDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface NativoORTBDevice : PBMORTBDevice

// Just used for testing until Ad Server supports finding IP address dynamically
@property (nonatomic, strong, nullable) NSString * ip;

@end

NS_ASSUME_NONNULL_END
