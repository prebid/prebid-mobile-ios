//
//  PBMAdLoadFlowState.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMAdLoadFlowState) {
    PBMAdLoadFlowState_Idle = 0,
    
    PBMAdLoadFlowState_BidRequest,
    PBMAdLoadFlowState_DemandReceived,
    PBMAdLoadFlowState_PrimaryAdRequest,
    PBMAdLoadFlowState_LoadingDisplayView, // skipped if primaryAdServer wins
    PBMAdLoadFlowState_ReadyToDeploy,
    
    PBMAdLoadFlowState_LoadingFailed = -1,
};
