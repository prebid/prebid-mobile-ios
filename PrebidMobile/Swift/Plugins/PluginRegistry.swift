/*   Copyright 2018-2026 Prebid.org, Inc.
 
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

/// Process-wide registration counter shared by all capabilities, so plugins registered for different
/// capabilities can be ordered against each other.
enum PluginRegistrationSequence {
    
    private static let lock = NSLock()
    private static var last: UInt64 = 0
    
    static func next() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        
        last += 1
        return last
    }
}

/// Thread-safe list of the plugins registered for one capability.
///
/// A plugin is identified by the `PrebidPluginInfo` that `identify` returns, and a plugin whose info
/// equals a registered one is ignored. A plugin becomes active once its `onRegister` returns; `active`
/// lists the active plugins in registration order. Plugin code (`identify`, `onRegister`, `onUnregister`)
/// always runs outside the lock, so a plugin may call back into the registry.
final class PluginRegistry<Plugin> {
    
    struct Entry {
        let sequence: UInt64
        let info: PrebidPluginInfo
        let plugin: Plugin
    }
    
    private final class Registration {
        
        enum State {
            /// `onRegister` is running. The plugin isn't active yet.
            case registering
            case active
            /// Unregistered, possibly while `onRegister` was still running.
            case removed
        }
        
        let entry: Entry
        var state = State.registering
        
        init(_ entry: Entry) {
            self.entry = entry
        }
    }
    
    /// The capability name, used in logs.
    let name: String
    
    private let identify: (Plugin) -> PrebidPluginInfo
    private let capacity: Int?
    private let onRegister: (Plugin) -> Void
    private let onUnregister: (Plugin) -> Void
    
    private let lock = NSLock()
    private var registrations = [Registration]()
    
    /// - Parameters:
    ///   - capacity: The maximum number of registered plugins, or `nil` for no limit.
    init(
        name: String,
        identify: @escaping (Plugin) -> PrebidPluginInfo,
        capacity: Int? = nil,
        onRegister: @escaping (Plugin) -> Void = { _ in },
        onUnregister: @escaping (Plugin) -> Void = { _ in }
    ) {
        self.name = name
        self.identify = identify
        self.capacity = capacity
        self.onRegister = onRegister
        self.onUnregister = onUnregister
    }
    
    /// The active plugins in registration order (a snapshot).
    var active: [Plugin] {
        activeEntries.map(\.plugin)
    }
    
    /// The entries of the active plugins in registration order (a snapshot).
    var activeEntries: [Entry] {
        synchronized {
            registrations.filter { $0.state == .active }.map(\.entry)
        }
    }
    
    /// Registers `plugin` and calls its `onRegister`. It's ignored if a plugin with equal info is
    /// registered, or if the registry is full.
    func add(_ plugin: Plugin) {
        let info = identify(plugin)
        
        var isFull = false
        let registration = synchronized { () -> Registration? in
            guard !registrations.contains(where: { $0.entry.info == info }) else {
                return nil
            }
            
            if let capacity, registrations.count >= capacity {
                isFull = true
                return nil
            }
            
            let registration = Registration(Entry(
                sequence: PluginRegistrationSequence.next(),
                info: info,
                plugin: plugin
            ))
            
            registrations.append(registration)
            return registration
        }
        
        guard let registration else {
            let reason = isFull ? "the capability accepts at most \(capacity ?? 0)" : "a plugin with the same identity is already registered"
            Log.warn("[\(name)] Plugin \(info) is not registered: \(reason).")
            return
        }
        
        onRegister(plugin)
        
        let isRemoved = synchronized { () -> Bool in
            if registration.state == .removed {
                return true
            }
            
            registration.state = .active
            return false
        }
        
        // Unregistered while `onRegister` was running: `remove` left `onUnregister` to this call,
        // so the two callbacks never overlap.
        guard !isRemoved else {
            onUnregister(plugin)
            return
        }
        
        Log.debug("[\(name)] Plugin \(info) registered.")
    }
    
    /// Unregisters the plugin whose info equals `plugin`'s and calls that plugin's `onUnregister`.
    /// No-op if no such plugin is registered.
    func remove(_ plugin: Plugin) {
        let info = identify(plugin)
        
        let removed = synchronized { () -> Registration? in
            guard let index = registrations.firstIndex(where: { $0.entry.info == info }) else {
                return nil
            }
            
            let registration = registrations.remove(at: index)
            let wasActive = registration.state == .active
            registration.state = .removed
            
            // A plugin that isn't active yet is still in `onRegister`; `add` calls `onUnregister`
            // once `onRegister` returns.
            return wasActive ? registration : nil
        }
        
        guard let removed else {
            return
        }
        
        onUnregister(removed.entry.plugin)
        Log.debug("[\(name)] Plugin \(info) unregistered.")
    }
    
    /// Returns whether an active plugin's info equals `plugin`'s.
    func contains(_ plugin: Plugin) -> Bool {
        let info = identify(plugin)
        
        return synchronized {
            registrations.contains { $0.state == .active && $0.entry.info == info }
        }
    }
    
    private func synchronized<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
