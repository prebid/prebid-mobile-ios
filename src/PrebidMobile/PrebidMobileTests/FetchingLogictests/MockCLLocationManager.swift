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
import CoreLocation
import MapKit

class RepeatingTimer {

    let timeInterval: TimeInterval

    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}

class MockCLLocationManager: CLLocationManager {
    private var timer: Timer?
    private var locations: CLLocation?
    private var _isRunning: Bool = false
    var updateInterval: TimeInterval = 0.1
    var isRunning: Bool {
            return _isRunning
    }
    static let shared = MockCLLocationManager()
    private override init() {

    }
    func startMocks(usingGpx fileName: String) {

    }
    func stopMocking() {
        self.stopUpdatingLocation()
    }
    private func updateLocation() {
        delegate?.locationManager?(self, didUpdateLocations: [locations!])

    }
    override func startUpdatingLocation() {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .default)
        }
    }
    
    @objc func loop() {
        self.locations = CLLocation(latitude: 28.5388, longitude: -81.3756)
        self.updateLocation()
    }
    
    override func stopUpdatingLocation() {
        timer?.invalidate()
        self.locations = nil
        _isRunning = false
    }
    override func requestLocation() {
        self.locations = CLLocation(latitude: 28.5388, longitude: -81.3756)
        delegate?.locationManager?(self, didUpdateLocations: [locations!])

    }
}
