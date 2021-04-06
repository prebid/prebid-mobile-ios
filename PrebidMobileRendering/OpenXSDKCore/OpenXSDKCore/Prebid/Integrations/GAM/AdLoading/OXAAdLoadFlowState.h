//
//  OXAAdLoadFlowState.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXAAdLoadFlowState) {
    OXAAdLoadFlowState_Idle = 0,
    
    OXAAdLoadFlowState_BidRequest,
    OXAAdLoadFlowState_DemandReceived,
    OXAAdLoadFlowState_PrimaryAdRequest,
    OXAAdLoadFlowState_LoadingDisplayView, // skipped if primaryAdServer wins
    OXAAdLoadFlowState_ReadyToDeploy,
    
    OXAAdLoadFlowState_LoadingFailed = -1,
};
