//
//  ConsentSyncSerialNetworkSession.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation


/// `ConsentSyncSerialNetworkSession` is a thread safe utility for serially performing non-duplicate consent sync requests with `MPHTTPNetworkSession`. `ConsentSyncSerialNetworkSession` provides the ability to deduplicate and prevent subsequent consent sync requests from being performed.
@objc(MPConsentSyncSerialNetworkSession)
public class ConsentSyncSerialNetworkSession: NSObject {
    // MARK: - Properties

    /// Specifies rules to compare requests
    let comparator: URLRequestComparable
    
    
    /// Network session class through which to perform network requests
    let networkSession: MPHTTPNetworkSession.Type
    
    // MARK: - Initialization
    
    /// Initializes the `ConsentSyncSerialNetworkSession` instance.
    /// - Parameter comparator: The object used to determine whether an added request is a duplicate of the last completed request.
    /// - Parameter networkSession: Class through which network requests are performed.
    /// - Returns: An initialized `ConsentSyncSerialNetworkSession`.
    public init(comparator: URLRequestComparable, networkSession: MPHTTPNetworkSession.Type) {
        self.comparator = comparator
        self.networkSession = networkSession
        super.init()
    }
    
    /// Convenience initializer to create a `ConsentSyncSerialNetworkSession` instance with `MPHTTPNetworkSession`
    /// - Returns: An initialized `ConsentSyncSerialNetworkSession`.
    @objc public override convenience init() {
        self.init(comparator: ConsentSynchronizationURLCompare(), networkSession: MPHTTPNetworkSession.self)
    }
    
    // MARK: - Private
    
    /// Task to encapsulate the request being made with its associated `responseHandler` and `errorHandler`.
    private struct Task {
        let request: MPURLRequest
        let responseHandler: ((Data?, URLResponse?) -> Void)?
        let errorHandler: ((Error?) -> Void)?
    }
    
    /// The pending task.
    private var pendingTask: Task?
    
    /// The currently in progress task.
    private var inProgressTask: Task?
    
    /// The last task completed successfully.
    private var lastCompletedTask: Task?
    
    /// Serial queue used to handle operations surrounding network requests.
    private let serialQueue = DispatchQueue(label: "com.mopub.mopub-ios-sdk.serialnetworksession.queue")
    
    // MARK: - Public functions
    
    
    /// Attempts to start a task with the provided `MPURLRequest` instance. Based on comparison results derived from the `URLRequestComparable` comparator, the request may not execute, and subsequently the `responseHandler` and `errorHandler` will not be invoked.
    /// - Parameter request: Request to send.
    /// - Parameter responseHandler: Optional response handler that will be invoked on the main thread.
    /// - Parameter errorHandler: Optional error handler that will be invoked on the main thread.
    @objc public func attemptTask(with request: MPURLRequest, responseHandler: ((Data?, URLResponse?) -> Void)?, errorHandler: ((Error?) -> Void)?) -> Void {
        serialQueue.async { [weak self] in
            // Obtain strong reference to self, otherwise don't bother.
            guard let self = self else { return }
            
            // Create a task based on the request.
            let task = Task(request: request, responseHandler: responseHandler, errorHandler: errorHandler)
            
            // Immediately set as pending task, overwritting any pending tasks that may exist.
            MPLogging.logEvent(with: "Setting URL request as pending: \(task.request.url?.absoluteString ?? "")", from: ConsentSyncSerialNetworkSession.self)
            self.pendingTask = task
            
            // Determine if pending task should be executed.
            self.executePendingTaskIfNecessary()
        }
    }
    
    // MARK: - Private functions
    
    /// Performs the pending request if it is not a duplicate of the last completed request. This function should only execute on the `serialQueue`.
    private func executePendingTaskIfNecessary() {
        // This function should only be executed of the serialQueue.
        dispatchPrecondition(condition: .onQueue(serialQueue))
        
        MPLogging.logEvent(with: "Determining if next request should be executed.", from: ConsentSyncSerialNetworkSession.self)
        
        // Only execute if there are no tasks in progress
        guard self.inProgressTask == nil else {
            MPLogging.logEvent(with: "Request in progress. Waiting to execute until complete.", from: ConsentSyncSerialNetworkSession.self)
            return
        }
        
        // If there are no pending requests to execute, return immediately.
        guard let pendingTask = pendingTask else {
            MPLogging.logEvent(with: "No pending requests to execute", from: ConsentSyncSerialNetworkSession.self)
            return
        }
        
        // If the pending request is a duplicate of the last completed request, we won't execute the task. Discard it by removing the pending task.
        if let lastCompletedTask = lastCompletedTask, comparator.isRequest(pendingTask.request, duplicateOf: lastCompletedTask.request) {
            MPLogging.logEvent(with: "Pending request \(pendingTask.request.url?.absoluteString ?? "") is a duplicate of last completed request \(lastCompletedTask.request.url?.absoluteString ?? ""). Will discard.", from: ConsentSyncSerialNetworkSession.self)
            self.pendingTask = nil
        }
        // If the pending request waiting to be executed is not a duplicate of the last completed request, let's execute it.
        else if !comparator.isRequest(pendingTask.request, duplicateOf: lastCompletedTask?.request) {
            MPLogging.logEvent(with: "Pending request \(pendingTask.request.url?.absoluteString ?? "") is not a duplicate of last completed request. Will execute.", from: ConsentSyncSerialNetworkSession.self)
            let inProgressTask = pendingTask
            
            // Set inProgressTask and remove pendingTask.
            self.inProgressTask = inProgressTask
            self.pendingTask = nil
            
            networkSession.startTask(withHttpRequest: inProgressTask.request as URLRequest) { [weak self] (data, urlResponse) in
                self?.handleResponse(for: inProgressTask, data: data, urlResponse: urlResponse)
            } errorHandler: { [weak self] (error) in
                self?.handleResponse(for: inProgressTask, error: error)
            }
        }
    }
    
    /// Handles the response invoked by the internal network session.
    private func handleResponse(for task: Task, data: Data? = nil, urlResponse: HTTPURLResponse? = nil, error: Error? = nil) {
        self.serialQueue.async { [weak self] in
            // Obtain strong reference to self, otherwise don't bother.
            guard let self = self else { return }
            
            MPLogging.logEvent(with: "Finished request: \(task.request.url?.absoluteString ?? "") \(error != nil ? ", error: \(error!.localizedDescription)" : "")", from: ConsentSyncSerialNetworkSession.self)
            
            // Remove the in progress task.
            self.inProgressTask = nil
            
            // If finished successfully, set the task as last completed.
            if error == nil {
                self.lastCompletedTask = task
            }
            
            // Call the proper response handler on the main thread.
            DispatchQueue.main.async {
                if error == nil {
                    task.responseHandler?(data, urlResponse)
                } else {
                    task.errorHandler?(error)
                }
            }
            
            // Execute the next pending task if necessary.
            self.executePendingTaskIfNecessary()
        }
    }
}


extension MPLogging {
    static func logEvent(with message: String, level: MPBLogLevel = .debug, from someClass: AnyClass? = nil) {
        MPLogging.logEvent(MPLogEvent(message: message, level: level), source: nil, from: someClass)
    }
}
