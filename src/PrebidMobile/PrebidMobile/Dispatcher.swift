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

protocol DispatcherDelegate: class {
    func refreshDemand()
}

open class Dispatcher:NSObject {
    
    var timer : Timer?
    
    var delegate: DispatcherDelegate!
    
    var repeatInSeconds:Double = 0
    
    init(withDelegate:DispatcherDelegate, autoRefreshMillies:Double) {
        
        //timer takes values in seconds...
        repeatInSeconds = autoRefreshMillies/1000
        delegate = withDelegate
        
        super.init()
        
    }
    
    open func invalidate() {
        stop()
        delegate = nil
    }
    
    func start() {
        
        stop()
        
        self.timer = Timer.scheduledTimer(timeInterval: repeatInSeconds, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        RunLoop.main.add(self.timer!, forMode: .commonModes)
        
    }
    
    func stop() {
        if(self.timer != nil){
            self.timer?.invalidate();
            self.timer = nil;
        }
    }
    
    @objc func fireTimer(){
        delegate?.refreshDemand()
    }
    
    

}
