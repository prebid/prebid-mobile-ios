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
        interstitialController.modalPresentationStyle = .fullScreen
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoImaView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(videoImaView)

        videoImaView.setAutoPlayAndShowAd()
        
        layoutInterstitial()

        self.view.autoresizesSubviews = true
    }
    
    // MARK: - layout
    override func viewWillLayoutSubviews() {
        videoImaView.frame = UIScreen.main.bounds
        
        layoutInterstitial()
    }

    // MARK: - Disappear
    override func viewWillDisappear(_ animated: Bool) {
        
        videoImaView.reset()
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: = fileprivate
    fileprivate func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - private
    private func layoutInterstitial() {
        
        if UIDevice.current.orientation == .portrait {
            viewDidEnterPortrait()
        } else if UIDevice.current.orientation.isLandscape {
            viewDidEnterLandscape()
        }
    }
    
    private func viewDidEnterPortrait() {
        
        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            // Fallback on earlier versions
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        let muteSwitcher = videoImaView.muteSwitcher!
        muteSwitcher.frame = CGRect(x: 0, y: statusBarHeight, width: muteSwitcher.frame.width, height: muteSwitcher.frame.height)
    }
    
    private func viewDidEnterLandscape() {
        
        let muteSwitcher = videoImaView.muteSwitcher!
        muteSwitcher.frame = CGRect(x: self.view.layoutMargins.left, y: 0, width: muteSwitcher.frame.width, height: muteSwitcher.frame.height)
    }
    
}
