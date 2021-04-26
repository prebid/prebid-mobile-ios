//
//  PBMNSThreadProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PBMNSThreadProtocol

@property (readonly) BOOL isMainThread;

@end

@interface NSThread (PBMNSThreadProtocol) <PBMNSThreadProtocol>
@end
