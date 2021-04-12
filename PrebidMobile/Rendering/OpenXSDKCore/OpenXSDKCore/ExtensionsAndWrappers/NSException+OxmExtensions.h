//
//  NSException+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSException (OxmExtensions)

+ (nonnull NSException *)oxmException:(nonnull NSString*)message;

@end
