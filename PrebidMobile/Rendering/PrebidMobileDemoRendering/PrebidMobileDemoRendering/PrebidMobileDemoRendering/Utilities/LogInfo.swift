//
//  LogInfo.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

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
    
    let logMessage = "PrebidMobileRendering INFO \(threadName) \(formattedDate) \(file) \(function) [Line \(line)] \(message)"
    print(logMessage)
}
