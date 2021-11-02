//
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

public class ImpressionTasksExecutor {
    
    static let shared = ImpressionTasksExecutor()
    
    private let queue = DispatchQueue(label: "impressionQueue", qos: .background)
    
    private(set) var arrayOfTasks = [ImpressionTask]() {
        didSet {
            queue.async {
                if !self.isExecuting {
                    self.runFirstTask()
                }
            }
        }
    }
    
    private(set) var isExecuting = false
    
    private init() {}
    
    func add(tasks: [ImpressionTask]) {
        queue.async {
            self.arrayOfTasks += tasks
        }
    }
    
    func runFirstTask() {
        guard !self.arrayOfTasks.isEmpty else { return }
        guard !self.isExecuting else { return }
        self.isExecuting = true
        let firstTask = self.arrayOfTasks.removeFirst()
        queue.async {
            firstTask.task({ [weak self] in
                guard let self = self else { return }
                self.isExecuting = false
                self.queue.asyncAfter(deadline: .now() + .seconds(firstTask.delayInterval)) {
                    if !self.arrayOfTasks.isEmpty {
                        self.runFirstTask()
                    }
                }
            })
        }
    }
}
