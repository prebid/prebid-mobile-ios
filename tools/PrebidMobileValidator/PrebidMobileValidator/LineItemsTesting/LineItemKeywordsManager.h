#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface LineItemKeywordsManager : NSObject

+ (id) sharedManager;

- (NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(NSString *)bidPrice forSize:(NSString *)sizeString usingLocalCache:(BOOL) useLocalCache;


@end
