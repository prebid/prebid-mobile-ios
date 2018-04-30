#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface LineItemKeywordsManager : NSObject

+ (id) sharedManager;

/**
 * The bid price is passed in & a dictionary of keys & values from the bid response object is created
 */
- (NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(double)bidPrice forSize:(NSString *)sizeString usingLocalCache:(BOOL) useLocalCache;


@end
