//
//  DebounceService.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

//
//  DebounceService.swift
//  BravoBall
//
//  Created by Jordan on 6/9/25.
//

import Foundation

class DebounceService {
    static let shared = DebounceService()
    
    private var debounceWorkItems: [String: DispatchWorkItem] = [:]
    private var lastRequestTimes: [String: Date] = [:]
    private let defaultDebounceInterval: TimeInterval = 1.0 // 1 second default debounce
    private let minimumRequestInterval: TimeInterval = 0.5 // Minimum time between requests
    
    private init() {}
    
    /// Debounces a request with the given key and interval
    /// - Parameters:
    ///   - key: Unique identifier for the request type
    ///   - interval: Optional custom debounce interval (defaults to 1 second)
    /// - Returns: Boolean indicating if the request should proceed
    func shouldProceedWithRequest(key: String, interval: TimeInterval? = nil) -> Bool {
        // Cancel any existing work item for this key
        debounceWorkItems[key]?.cancel()
        
        // Check if enough time has passed since last request
        if let lastRequestTime = lastRequestTimes[key],
           Date().timeIntervalSince(lastRequestTime) < (interval ?? defaultDebounceInterval) {
            print("[Debounce] Skipping request for key '\(key)' - too soon since last request")
            return false
        }
        
        // Update last request time
        lastRequestTimes[key] = Date()
        return true
    }
    
    /// Cancels any pending debounced request for the given key
    /// - Parameter key: The key of the request to cancel
    func cancelRequest(for key: String) {
        debounceWorkItems[key]?.cancel()
        debounceWorkItems.removeValue(forKey: key)
    }
    
    /// Clears all pending debounced requests
    func clearAllRequests() {
        debounceWorkItems.values.forEach { $0.cancel() }
        debounceWorkItems.removeAll()
        lastRequestTimes.removeAll()
    }
} 
