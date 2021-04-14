//
//  OXMHTMLFormatter.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OXMHTMLFormatter : NSObject

+ (nonnull NSString *)ensureHTMLHasBodyAndHTMLTags:(nonnull NSString *)html;

@end
