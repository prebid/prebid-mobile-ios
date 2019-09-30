/*   Copyright 2018-2019 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import Foundation

@objcMembers
public class VideoImaInterstitial: NSObject, VideoImaDelegate, PBVideoAdDelegate {
    
    public weak var interstitialDelegate: PBVideoAdInterstitialDelegate?
    
    private let interstitialController: InterstitialController
    private let videoImaView: VideoImaView
    
    private var isReady = false
    
    public override init() {
        
        interstitialController = InterstitialController()
        videoImaView = VideoImaView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        interstitialController.videoImaView = videoImaView
        
        super.init()
        
        videoImaView.pbVideoAdDelegate = self
        videoImaView.add(videoImaDelegate: self)
    }
    
    public func loadAd(videoInterstitialAdUnit: VideoInterstitialAdUnit, adUnitId: String) {
        isReady = false;
        videoImaView.loadAdWithoutAutoPlay(adUnit: videoInterstitialAdUnit, adUnitId: adUnitId)
    }
    
    public func show(from: UIViewController) {

        if (isReady == false) {
            interstitialDelegate?.videoAdInterstitialFailed()
            return
        }
        from.present(interstitialController, animated: true, completion: nil)
        
    }
    
    // MARK: - VideoImaDelegate
    func adLoaded() {
        isReady = true;
        interstitialDelegate?.videoAdInterstitialLoaded()
    }
    
    func adSkipped() {
        interstitialDelegate?.videoAdInterstitialCancelled()
    }
    
    func adFinished() {
        interstitialDelegate?.videoAdInterstitialCompleted()
    }
    
    func adPlayingFailed() {
        interstitialDelegate?.videoAdInterstitialFailed()
    }
    
    func allAdsCompleted() {
        interstitialController.dismiss()
    }
    
    // MARK: - PBVideoAdDelegate
    public func videoAd(event: PBVideoAdEvent) {
        interstitialDelegate?.videoAdInterstitial(event: event)
    }
    
}

private class InterstitialController: UIViewController {
    
    fileprivate var videoImaView: VideoImaView!
    
    private var fullscreenVideoFrame: CGRect?
    private var portraitVideoViewFrame: CGRect?
    private var portraitVideoFrame: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let videoViewBounds = self.view.bounds
        portraitVideoViewFrame = self.view.frame
        portraitVideoFrame = CGRect(x: 0, y: 0, width: videoViewBounds.size.width, height: videoViewBounds.size.height)
        
        videoImaView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(videoImaView)

        

        
        videoImaView.setAutoPlayAndShowAd()
        
        updateMuteSwitcherPosition()
    }
    
    private func updateMuteSwitcherPosition() {
        let muteSwitcher = videoImaView.muteSwitcher!
        var x = CGFloat()
        var y = CGFloat()
        if (UIApplication.shared.statusBarOrientation.isPortrait) {
            //DO Portrait
            x = CGFloat(0)
            y = CGFloat(UIApplication.shared.statusBarFrame.size.height)
        } else {
            //DO Landscape
            x = CGFloat(self.view.layoutMargins.left)
            y = CGFloat(0)
        }
        
        muteSwitcher.frame = CGRect(x: x, y: y, width: muteSwitcher.frame.width, height: muteSwitcher.frame.height)
    }

    fileprivate func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - rotate
    override func didRotate(from interfaceOrientation: UIInterfaceOrientation) {
        switch (interfaceOrientation) {
        case UIInterfaceOrientation.landscapeLeft: fallthrough
        case UIInterfaceOrientation.landscapeRight:
            viewDidEnterPortrait()
            updateMuteSwitcherPosition()
            break
        case UIInterfaceOrientation.portrait: fallthrough
        case UIInterfaceOrientation.portraitUpsideDown:
            viewDidEnterLandscape()
            updateMuteSwitcherPosition()
            break
        case UIInterfaceOrientation.unknown:
            break
        @unknown default:
            break
        }
    }
    
    func viewDidEnterLandscape() {
        
        let screenRect = UIScreen.main.bounds
        if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
            fullscreenVideoFrame = CGRect(x: 0, y: 0, width: screenRect.size.height, height: screenRect.size.width)
        } else {
            fullscreenVideoFrame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        }

        videoImaView.frame = fullscreenVideoFrame!
    }
    
    func viewDidEnterPortrait() {

        videoImaView.frame = portraitVideoViewFrame!
    }
    
    // MARK: - Disappear
    override func viewWillDisappear(_ animated: Bool) {
        
        videoImaView.reset()
        
        super.viewWillDisappear(animated)
    }
    
}
