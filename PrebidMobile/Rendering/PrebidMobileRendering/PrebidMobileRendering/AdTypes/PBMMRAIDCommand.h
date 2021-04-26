//
//  PBMMRAIDCommand.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMMRAIDConstants.h"

@interface PBMMRAIDCommand : NSObject

@property (nonatomic, readonly, nonnull) PBMMRAIDAction command;
@property (nonatomic, readonly, nonnull) NSArray<NSString *> *arguments;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithURL:(nonnull NSString *)url error:(NSError* _Nullable __autoreleasing * _Nullable)error NS_DESIGNATED_INITIALIZER;

@end
