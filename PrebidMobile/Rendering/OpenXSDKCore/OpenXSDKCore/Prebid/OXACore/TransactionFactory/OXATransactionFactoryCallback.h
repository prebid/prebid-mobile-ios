//
//  OXATransactionFactoryCallback.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class OXMTransaction;

typedef void (^OXATransactionFactoryCallback)(OXMTransaction * _Nullable, NSError * _Nullable);
