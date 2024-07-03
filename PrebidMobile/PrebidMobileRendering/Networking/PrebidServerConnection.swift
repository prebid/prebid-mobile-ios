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

fileprivate let HTTPMethodGET  = "GET"
fileprivate let HTTPMethodHEAD = "HEAD"
fileprivate let HTTPMethodPOST = "POST"

@objcMembers
public class PrebidServerConnection: NSObject, PrebidServerConnectionProtocol, URLSessionDelegate {
    
    // MARK: - Public properties
    
    public private(set) var userAgentService = UserAgentService.shared
    
    public var protocolClasses: [URLProtocol.Type] = []
    
    public static let shared = PrebidServerConnection()
    
    public static var userAgentHeaderKey: String {
        "User-Agent"
    }
    
    public static var contentTypeKey: String {
        "Content-Type"
    }
    
    public static var contentTypeVal: String {
        "application/json"
    }
    
    // The key for request's header where Connection places the ConnectionID
    // Must be used only in tests.
    public static var internalIDKey: String {
        "PBMConnectionID"
    }
    
    // The key for request's header of PBM PrebidServerConnection requests
    // Must be used only in tests.
    public static var isPBMRequestKey: String {
        "PBMIsPBMRequest"
    }
    
    // MARK: - Private properties
    
    // The unique identifier of connection. Predominantly uses in tests.
    let internalID = UUID()
    
    // MARK: Init
    
    public convenience init(userAgentService: UserAgentService) {
        self.init()
        self.userAgentService = userAgentService
    }
    
    // MARK: - Public methods
    
    public func fireAndForget(_ resourceURL: String?) {
        guard var request = createRequest(resourceURL) else {
            return
        }
        
        request.httpMethod = HTTPMethodGET
        
        let session = createSession(PBMTimeInterval.FIRE_AND_FORGET_TIMEOUT)
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    // HEAD is the same as GET but the server doesn't return a body.
    public func head(_ resourceURL: String?, timeout: TimeInterval, callback: @escaping (PrebidServerResponse) -> Void) {
        getFor(resourceURL, timeout: timeout, headersOnly: true, callback: callback)
    }
    
    public func get(_ resourceURL: String?, timeout: TimeInterval = 0, callback: @escaping (PrebidServerResponse) -> Void) {
        getFor(resourceURL, timeout: timeout, headersOnly: false, callback: callback)
    }
    
    public func post(_ resourceURL: String?, data: Data?, timeout: TimeInterval,
                     callback: @escaping (PrebidServerResponse) -> Void) {
        post(resourceURL, contentType: PrebidServerConnection.contentTypeVal, data: data, timeout: timeout, callback: callback)
    }
    
    public func post(_ resourceURL: String?, contentType: String?,data: Data?, timeout: TimeInterval,
                     callback: @escaping (PrebidServerResponse) -> Void) {
        guard var request = createRequest(resourceURL) else {
            return
        }
        
        request.httpMethod = HTTPMethodPOST
        request.timeoutInterval = timeout
        request.setValue(contentType, forHTTPHeaderField: PrebidServerConnection.contentTypeKey)
        
        let session = createSession(timeout)
        let task = session.uploadTask(with: request, from: data) { [weak self] data, response, error in
            self?.proccessResponse(request, urlResponse: response, responseData: data, error: error, fullServerCallback: callback)
        }
        
        task.resume()
    }
    
    public func download(_ resourceURL: String?, callback: @escaping (PrebidServerResponse) -> Void) {
        guard var request = createRequest(resourceURL) else {
            return
        }
        
        request.setValue(PrebidServerConnection.contentTypeVal, forHTTPHeaderField: PrebidServerConnection.contentTypeKey)
        
        let session = createSession(PBMTimeInterval.FIRE_AND_FORGET_TIMEOUT)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.proccessResponse(request, urlResponse: response,
                                   responseData: data, error: error, fullServerCallback: callback)
        }
        
        task.resume()
    }
    
    // MARK: Private methods
    
    private func getFor(_ resourceURL: String?, timeout: TimeInterval, headersOnly: Bool,
                        callback: @escaping PrebidServerResponseCallback) {
        guard var request = createRequest(resourceURL) else {
            return
        }
        
        request.httpMethod = headersOnly ? HTTPMethodHEAD : HTTPMethodGET
        request.timeoutInterval = timeout
        request.setValue(PrebidServerConnection.contentTypeVal, forHTTPHeaderField: PrebidServerConnection.contentTypeKey)
        
        let session = createSession(timeout)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.proccessResponse(request, urlResponse: response,
                                   responseData: data, error: error, fullServerCallback: callback)
        }
        
        task.resume()
    }
    
    private func proccessResponse(_ request: URLRequest, urlResponse: URLResponse?,
                                  responseData: Data?, error: Error?,
                                  fullServerCallback: PrebidServerResponseCallback) {
        
        let serverResponse = PrebidServerResponse()
        
        serverResponse.requestURL = request.url?.path
        serverResponse.requestHeaders = request.allHTTPHeaderFields
        
        // If there is an error, we don't care about the body
        guard error == nil else {
            serverResponse.error = error
            fullServerCallback(serverResponse)
            return
        }
        
        // Get HTTPURLResponse-specific fields
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            serverResponse.error = PBMError.error(message: "Response is not an HTTPURLResponse",
                                                  type: PBMErrorType.serverError)
            fullServerCallback(serverResponse)
            return
        }
        
        var responseHeaders = [String: String]()
        httpURLResponse
            .allHeaderFields
            .forEach { key, value in
                responseHeaders["\(key)"] = "\(value)"
            }
        
        serverResponse.responseHeaders = responseHeaders
        serverResponse.statusCode = httpURLResponse.statusCode
        
        // Body should be ignored if HEAD method was used
        if request.httpMethod != HTTPMethodHEAD {
            guard let responseData = responseData else {
                serverResponse.error = PBMError.error(message: "No data from server", type: PBMErrorType.serverError)
                fullServerCallback(serverResponse)
                return
            }
            
            serverResponse.rawData = responseData
            
            // Attempt to parse if response is JSON
            if let contentType = responseHeaders[PrebidServerConnection.contentTypeKey],
               contentType.contains(PrebidServerConnection.contentTypeVal) {
                do {
                    let json = try PBMFunctions.dictionaryFromData(responseData)
                    serverResponse.jsonDict = json
                } catch let parsingError {
                    let error = PBMError.error(message: "JSON Parsing Error: \(parsingError.localizedDescription)",
                                               type: PBMErrorType.internalError)
                    serverResponse.error = error
                }
            }
        }
        
        fullServerCallback(serverResponse)
    }
    
    private func createSession(_ timeout: TimeInterval) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.httpCookieAcceptPolicy = .never
        config.httpCookieStorage = nil
        config.timeoutIntervalForRequest = timeout
        config.protocolClasses = protocolClasses
        
        #if DEBUG
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return URLSession(configuration: config, delegate: self, delegateQueue: queue)
        #else
        return URLSession(configuration: config)
        #endif
    }
    
    private func createRequest(_ strUrl: String?) -> URLRequest? {
        guard let strUrl = strUrl else {
            Log.error("No resource URL string was provided")
            return nil
        }
        
        guard let url = URL.urlWithoutEncoding(from: strUrl) else {
            Log.error("URL creation failed for string: \(strUrl)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(userAgentService.userAgent, forHTTPHeaderField: PrebidServerConnection.userAgentHeaderKey)
        request.setValue("True", forHTTPHeaderField: PrebidServerConnection.isPBMRequestKey)
        
        // Add this header only in test mode for MOCKED protocols
        if protocolClasses.count > 0 {
            request.addValue(internalID.uuidString, forHTTPHeaderField: PrebidServerConnection.internalIDKey)
        }
        
        // Prebid custom headers
        for (key, value) in Prebid.shared.customHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    #if DEBUG
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        PBMFunctions.checkCertificateChallenge(challenge, completionHandler: completionHandler)
    }
    #endif
}
