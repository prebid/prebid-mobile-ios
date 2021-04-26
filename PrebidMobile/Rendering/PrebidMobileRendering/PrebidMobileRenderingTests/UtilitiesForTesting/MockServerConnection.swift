//
//  MockServerConnection.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation
import XCTest

class MockServerConnection: NSObject, PBMServerConnectionProtocol {
    typealias FireAndForgetHandler = (String)->()
    typealias GetHandler = (String, TimeInterval, @escaping PBMServerResponseCallback) -> ()
    typealias PostHandler = (String, String, Data, TimeInterval, @escaping PBMServerResponseCallback) -> ()
    typealias PostHandler_NoContentType = (String, Data, TimeInterval, @escaping PBMServerResponseCallback) -> ()
    typealias DownloadHandler = (String, @escaping PBMServerResponseCallback) -> ()
    
    let defaultContentType = "application/json" // Note: Must be equivalent to PBMContentTypeVal
    
    let userAgentService: PBMUserAgentService? = nil
    
    private(set) var onFireAndForget: [FireAndForgetHandler]
    private(set) var onHead: [GetHandler]
    private(set) var onGet: [GetHandler]
    private(set) var onPost: [PostHandler]
    private(set) var onDownload: [DownloadHandler]
    
    init(onFireAndForget: [FireAndForgetHandler] = [], onHead: [GetHandler] = [], onGet: [GetHandler] = [], onPost: [PostHandler], onDownload: [DownloadHandler] = []) {
        self.onFireAndForget = onFireAndForget
        self.onHead = onHead
        self.onGet = onGet
        self.onPost = onPost
        self.onDownload = onDownload
    }
    
    // to be used when test is not interested in contentType being post
    convenience init(onFireAndForget: [FireAndForgetHandler] = [],
                     onHead: [GetHandler] = [],
                     onGet: [GetHandler] = [],
                     onPost: [PostHandler_NoContentType] = [],
                     onDownload: [DownloadHandler] = [])
    {
        self.init(onFireAndForget: onFireAndForget,
                  onHead: onHead,
                  onGet: onGet,
                  onPost: onPost.map { (nextOnPost) -> PostHandler in
                    { (url, contentType, data, timeout, callback) in
                        nextOnPost(url, data, timeout, callback)
                    }
                  },
                  onDownload: onDownload)
    }
    
    // to be used when test is not expecting any post messages
    convenience init(onFireAndForget: [FireAndForgetHandler] = [],
                     onHead: [GetHandler] = [],
                     onGet: [GetHandler] = [],
                     onDownload: [DownloadHandler] = [])
    {
        self.init(onFireAndForget: onFireAndForget,
                  onHead: onHead,
                  onGet: onGet,
                  onPost: [PostHandler](),
                  onDownload: onDownload)
    }
    
    func fireAndForget(_ resourceURL: String) {
        guard onFireAndForget.count > 0 else {
            XCTFail("No handler for \(#function) request {\n\t\(resourceURL)\n}")
            return
        }
        let handler = onFireAndForget.remove(at: 0)
        handler(resourceURL)
    }
    
    func head(_ resourceURL: String, timeout: TimeInterval, callback: @escaping PBMServerResponseCallback) {
        guard onHead.count > 0 else {
            XCTFail("No handler for \(#function) request {\n\t\(resourceURL)\n\t\(timeout)\n}")
            return
        }
        let handler = onHead.remove(at: 0)
        handler(resourceURL, timeout, callback)
    }
    
    func get(_ resourceURL: String, timeout: TimeInterval, callback: @escaping PBMServerResponseCallback) {
        guard onGet.count > 0 else {
            XCTFail("No handler for \(#function) request {\n\t\(resourceURL)\n\t\(timeout)\n}")
            return
        }
        let handler = onGet.remove(at: 0)
        handler(resourceURL, timeout, callback)
    }
    
    func post(_ resourceURL: String, contentType: String, data: Data, timeout: TimeInterval, callback: @escaping PBMServerResponseCallback) {
        guard onPost.count > 0 else {
            XCTFail("No handler for \(#function) request {\n\t\(resourceURL)\n\t\(data)\n\t\(timeout)\n}")
            return
        }
        let handler = onPost.remove(at: 0)
        handler(resourceURL, contentType, data, timeout, callback)
    }
    func post(_ resourceURL: String, data: Data, timeout: TimeInterval, callback: @escaping PBMServerResponseCallback) {
        post(resourceURL, contentType: defaultContentType, data: data, timeout: timeout, callback: callback)
    }
    
    func download(_ resourceURL: String, callback: @escaping PBMServerResponseCallback) {
        guard onDownload.count > 0 else {
            XCTFail("No handler for \(#function) request {\n\t\(resourceURL)\n}")
            return
        }
        let handler = onDownload.remove(at: 0)
        handler(resourceURL, callback)
    }
}
