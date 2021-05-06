//
//  PBMMediaViewDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol MediaViewDelegate {
    func onMediaViewPlaybackStarted(_ mediaView: MediaView)
    func onMediaViewPlaybackFinished(_ mediaView: MediaView)
    
    func onMediaViewPlaybackPaused(_ mediaView: MediaView)
    func onMediaViewPlaybackResumed(_ mediaView: MediaView)
    
    func onMediaViewPlaybackMuted(_ mediaView: MediaView)
    func onMediaViewPlaybackUnmuted(_ mediaView: MediaView)
    
    func onMediaViewLoadingFinished(_ mediaView: MediaView)
}
