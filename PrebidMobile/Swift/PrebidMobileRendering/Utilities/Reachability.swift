/*   Copyright 2018-2021 Prebid.org, Inc.

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

import Foundation
import SystemConfiguration

public typealias PBMNetworkReachableBlock = (Reachability?) -> Void

@objc(PBMReachability) @objcMembers
public class Reachability: NSObject {
    
    // MARK: - Public properties
    
    /**
     * Shared instance for checking whether the default route is available.
     */
    public static let shared = Reachability()
    
    public var currentReachabilityStatus: NetworkType {
        guard let reachabilityRef = reachabilityRef else {
            Log.error("currentReachabilityStatus called with NULL SCNetworkReachabilityRef")
            return .unknown
        }
        
        var networkType: NetworkType = .offline
        
        var flags = SCNetworkReachabilityFlags()
        
        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
            networkType = networkStatus(for: flags)
        }
        
        return networkType
    }
    
    /**
     * Returns true is network is reachable otherwise returns false
     */
    public var isNetworkReachable: Bool {
        return currentReachabilityStatus != .offline && currentReachabilityStatus != .unknown
    }
    
    // MARK: - Private properties
    
    private var reachabilityRef: SCNetworkReachability?
    private var reachableBlock: PBMNetworkReachableBlock?
    
    private override init() {
        super.init()
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &zeroAddress)
    }
    
    deinit {
        stopNotifier()
        reachabilityRef = nil
    }
    
    public func stopNotifier() {
        if reachableBlock != nil, let reachabilityRef = reachabilityRef {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            self.reachableBlock = nil
        }
    }
    
    /**
     * Starts monitoring of the network status.
     * Calls the reachableBlock when network is restored
     */
    public func onNetworkRestored(_ reachableBlock: @escaping PBMNetworkReachableBlock) {
        self.reachableBlock = reachableBlock
        guard let reachabilityRef = self.reachabilityRef else {
            return
        }
        
        var context = SCNetworkReachabilityContext(version: 0, info: Unmanaged<Reachability>.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        
        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            
            guard let info = info else { return }
            let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
            
            if reachability.networkStatus(for: flags) != .offline {
                reachability.reachableBlock?(reachability)
                reachability.stopNotifier()
            }
        }
        
        if SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        }
    }
    
    private func networkStatus(for flags: SCNetworkReachabilityFlags) -> NetworkType {
        var networkType: NetworkType = .offline
        
        // The target host is not reachable.
        if !flags.contains(.reachable) {
            return networkType
        }
        
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        if !flags.contains(.connectionRequired) {
            networkType = .wifi
        }
        
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
         ... and no [user] intervention is needed
         */
        if flags.contains(.connectionOnDemand) ||
            flags.contains(.connectionOnTraffic) &&
            !flags.contains(.connectionRequired) {
            networkType = .wifi
        }
        
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        if flags.contains(.isWWAN) {
            networkType = .celluar
        }
        
        return networkType
    }
}
