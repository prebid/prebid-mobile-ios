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

fileprivate let dateFormatter: DateFormatter = {
    let result = DateFormatter()
    result.dateFormat = "MM-dd HH:mm:ss:SSSS"
    return result
}()

func logInfo(_ message: String,
             file: StaticString = #file,
             line: UInt = #line,
             function: StaticString = #function,
             thread: Thread? = nil)
{
    let formattedDate = dateFormatter.string(from: Date())
    
    let theThread = thread ?? Thread.current
    
    let threadName: String
    
    if theThread.isMainThread {
        threadName = "[MAIN]"
    } else {
        let threadDescr = theThread.description
        let threadNumberString = "number = "
        
        if let leftEdgeUp = threadDescr.range(of: threadNumberString)?.upperBound {
            let leftEdge = threadDescr.index(after: leftEdgeUp)
            let threadDescrTrimmedLeft = threadDescr[leftEdge...]
            if let rightEdge = threadDescrTrimmedLeft.firstIndex(of: ",") {
                let threadNameRaw = threadDescrTrimmedLeft[..<rightEdge]
                threadName = "[\(threadNameRaw)]"
            } else {
                threadName = "[\(threadDescrTrimmedLeft)]"
            }
        } else {
            threadName = "[???]"
        }
    }
    
    let logMessage = "PrebidMobile INFO \(threadName) \(formattedDate) \(file) \(function) [Line \(line)] \(message)"
    print(logMessage)
}
