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

import Foundation

protocol DispatcherDelegate: AnyObject {
    func refreshDemand()
}

class Dispatcher: NSObject {
    
    enum State {
        case notStarted
        case running
        case stopped
    }
    
    private(set) var state = State.notStarted

    var timer: Timer?

    weak var delegate: DispatcherDelegate!

    var repeatInSeconds: Double = 0
    
    var firingTime: Date?
    var stoppingTime: Date?
    
    init(withDelegate: DispatcherDelegate, autoRefreshMillies: Double) {

        delegate = withDelegate

        super.init()
        
        setAutoRefreshMillis(time: autoRefreshMillies)
    }
    
    func setAutoRefreshMillis(time: Double) {
        //timer takes values in seconds...
        repeatInSeconds = time/1000
    }

    func invalidate() {
        stop()
        delegate = nil
    }

    func start() {
        
        var remainSeconds: Double? = nil
        if let stoppingTime = self.stoppingTime, let firingTime = self.firingTime {
            remainSeconds = min(repeatInSeconds, max(0, (repeatInSeconds - stoppingTime.timeIntervalSince(firingTime))))
        }

        stop()
        
        state = .running
        stoppingTime = nil
        firingTime = Date()
        
        if let remainSeconds = remainSeconds {
            self.timer = Timer.scheduledTimer(timeInterval: remainSeconds,
                                              target: self,
                                              selector: #selector(fireTimerOnce),
                                              userInfo: nil,
                                              repeats: false)
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: repeatInSeconds,
                                              target: self,
                                              selector: #selector(fireTimer),
                                              userInfo: nil,
                                              repeats: true)
        }

        RunLoop.main.add(self.timer!, forMode: .common)

    }

    func stop() {
        state = .stopped
        
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
            
            stoppingTime = Date()
        }
    }

    @objc func fireTimer() {
        firingTime = Date()

        delegate?.refreshDemand()
    }
    
    @objc func fireTimerOnce() {
        fireTimer()
        stoppingTime = nil
        //run a regural timer with the set interval
        start()
    }

}
