//
//  OXMNSThreadProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OXMNSThreadProtocol

@property (readonly) BOOL isMainThread;

@end

@interface NSThread (OXMNSThreadProtocol) <OXMNSThreadProtocol>
@end
