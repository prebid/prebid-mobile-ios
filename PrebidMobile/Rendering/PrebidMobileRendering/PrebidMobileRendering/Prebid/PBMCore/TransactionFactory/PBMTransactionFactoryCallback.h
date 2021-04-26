//
//  PBMTransactionFactoryCallback.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class PBMTransaction;

typedef void (^PBMTransactionFactoryCallback)(PBMTransaction * _Nullable, NSError * _Nullable);
