//
//  NSException+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSException (PBMExtensions)

+ (nonnull NSException *)pbmException:(nonnull NSString*)message;

@end
