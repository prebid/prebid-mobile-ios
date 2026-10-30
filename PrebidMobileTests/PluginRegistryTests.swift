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

import XCTest
@testable import PrebidMobile

private final class MockPlugin {
    
    let info: PrebidPluginInfo
    
    /// Called from `onRegister`, before the event is recorded.
    var onRegisterAction: (() -> Void)?
    
    private let lock = NSLock()
    private var recordedEvents = [String]()
    
    init(name: String, version: String = "1.0") {
        info = PrebidPluginInfo(name: name, version: version)
    }
    
    var events: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recordedEvents
    }
    
    func record(_ event: String) {
        lock.lock()
        defer { lock.unlock() }
        recordedEvents.append(event)
    }
}

class PluginRegistryTests: XCTestCase {
    
    private var registry: PluginRegistry<MockPlugin>!
    
    override func setUp() {
        super.setUp()
        registry = makeRegistry()
    }
    
    override func tearDown() {
        registry = nil
        super.tearDown()
    }
    
    // MARK: - add
    
    func testAdd_activatesPluginsInRegistrationOrder() {
        let first = MockPlugin(name: "first")
        let second = MockPlugin(name: "second")
        let third = MockPlugin(name: "third")
        
        registry.add(first)
        registry.add(second)
        registry.add(third)
        
        XCTAssertEqual(registry.active.map(\.info.name), ["first", "second", "third"])
        XCTAssertTrue(registry.contains(second))
    }
    
    func testAdd_callsOnRegisterOnce() {
        let plugin = MockPlugin(name: "plugin")
        
        registry.add(plugin)
        
        XCTAssertEqual(plugin.events, ["onRegister"])
    }
    
    func testAdd_pluginIsNotActiveUntilOnRegisterReturns() {
        let plugin = MockPlugin(name: "plugin")
        var isActiveInOnRegister: Bool?
        var isContainedInOnRegister: Bool?
        plugin.onRegisterAction = { [unowned self, unowned plugin] in
            isActiveInOnRegister = registry.active.contains { $0 === plugin }
            isContainedInOnRegister = registry.contains(plugin)
        }
        
        registry.add(plugin)
        
        XCTAssertEqual(isActiveInOnRegister, false)
        XCTAssertEqual(isContainedInOnRegister, false)
        XCTAssertTrue(registry.contains(plugin))
    }
    
    func testAdd_equalInfo_keepsFirstPlugin() {
        let first = MockPlugin(name: "plugin", version: "1.0")
        let duplicate = MockPlugin(name: "plugin", version: "1.0")
        
        registry.add(first)
        registry.add(duplicate)
        
        XCTAssertEqual(registry.active.count, 1)
        XCTAssertTrue(registry.active.first === first)
        XCTAssertEqual(duplicate.events, [])
    }
    
    func testAdd_sameNameOtherVersion_registersBoth() {
        registry.add(MockPlugin(name: "plugin", version: "1.0"))
        registry.add(MockPlugin(name: "plugin", version: "2.0"))
        
        XCTAssertEqual(registry.active.map(\.info.version), ["1.0", "2.0"])
    }
    
    func testAdd_samePluginTwice_registersOnce() {
        let plugin = MockPlugin(name: "plugin")
        
        registry.add(plugin)
        registry.add(plugin)
        
        XCTAssertEqual(registry.active.count, 1)
        XCTAssertEqual(plugin.events, ["onRegister"])
    }
    
    func testAdd_capacityReached_ignoresPlugin() {
        registry = makeRegistry(capacity: 1)
        let first = MockPlugin(name: "first")
        let second = MockPlugin(name: "second")
        
        registry.add(first)
        registry.add(second)
        
        XCTAssertEqual(registry.active.map(\.info.name), ["first"])
        XCTAssertEqual(second.events, [])
        
        registry.remove(first)
        registry.add(second)
        
        XCTAssertEqual(registry.active.map(\.info.name), ["second"])
    }
    
    func testAdd_onRegisterMayCallBackIntoRegistry() {
        let plugin = MockPlugin(name: "plugin")
        let other = MockPlugin(name: "other")
        plugin.onRegisterAction = { [unowned self] in
            registry.add(other)
        }
        
        registry.add(plugin)
        
        XCTAssertEqual(Set(registry.active.map(\.info.name)), ["plugin", "other"])
    }
    
    func testAdd_assignsIncreasingSequenceAcrossRegistries() {
        let otherRegistry = makeRegistry()
        
        registry.add(MockPlugin(name: "a"))
        otherRegistry.add(MockPlugin(name: "b"))
        registry.add(MockPlugin(name: "c"))
        
        let a = registry.activeEntries[0].sequence
        let b = otherRegistry.activeEntries[0].sequence
        let c = registry.activeEntries[1].sequence
        
        XCTAssertLessThan(a, b)
        XCTAssertLessThan(b, c)
    }
    
    // MARK: - remove
    
    func testRemove_callsOnUnregisterAndDeactivates() {
        let plugin = MockPlugin(name: "plugin")
        registry.add(plugin)
        
        registry.remove(plugin)
        
        XCTAssertFalse(registry.contains(plugin))
        XCTAssertTrue(registry.active.isEmpty)
        XCTAssertEqual(plugin.events, ["onRegister", "onUnregister"])
    }
    
    func testRemove_equalInfo_removesRegisteredPlugin() {
        let registered = MockPlugin(name: "plugin")
        let other = MockPlugin(name: "plugin")
        registry.add(registered)
        
        registry.remove(other)
        
        XCTAssertTrue(registry.active.isEmpty)
        XCTAssertEqual(registered.events, ["onRegister", "onUnregister"])
        XCTAssertEqual(other.events, [])
    }
    
    func testRemove_unknownPlugin_isNoOp() {
        let registered = MockPlugin(name: "registered")
        let unknown = MockPlugin(name: "unknown")
        registry.add(registered)
        
        registry.remove(unknown)
        
        XCTAssertEqual(registry.active.count, 1)
        XCTAssertEqual(unknown.events, [])
    }
    
    func testRemove_duringOnRegister_callsOnUnregisterAfterOnRegisterReturns() {
        let plugin = MockPlugin(name: "plugin")
        plugin.onRegisterAction = { [unowned self, unowned plugin] in
            registry.remove(plugin)
            plugin.record("remove returned")
        }
        
        registry.add(plugin)
        
        XCTAssertEqual(plugin.events, ["remove returned", "onRegister", "onUnregister"])
        XCTAssertFalse(registry.contains(plugin))
        XCTAssertTrue(registry.active.isEmpty)
    }
    
    func testRemove_duringOnRegisterOnAnotherThread_callsOnUnregisterAfterOnRegisterReturns() {
        let plugin = MockPlugin(name: "plugin")
        let onRegisterStarted = DispatchSemaphore(value: 0)
        let removeReturned = DispatchSemaphore(value: 0)
        plugin.onRegisterAction = {
            onRegisterStarted.signal()
            removeReturned.wait()
        }
        
        let addReturned = expectation(description: "add returned")
        let registry = registry!
        DispatchQueue.global().async {
            registry.add(plugin)
            addReturned.fulfill()
        }
        
        onRegisterStarted.wait()
        registry.remove(plugin)
        plugin.record("remove returned")
        removeReturned.signal()
        
        wait(for: [addReturned], timeout: 5)
        
        XCTAssertEqual(plugin.events, ["remove returned", "onRegister", "onUnregister"])
        XCTAssertTrue(registry.active.isEmpty)
    }
    
    func testRemove_thenAdd_registersAgain() {
        let plugin = MockPlugin(name: "plugin")
        registry.add(plugin)
        registry.remove(plugin)
        
        registry.add(plugin)
        
        XCTAssertTrue(registry.contains(plugin))
        XCTAssertEqual(plugin.events, ["onRegister", "onUnregister", "onRegister"])
    }
    
    // MARK: - Concurrency
    
    func testConcurrentAdd_registersEveryPluginOnce() {
        let plugins = (0..<200).map { MockPlugin(name: "plugin-\($0 % 100)") }
        
        DispatchQueue.concurrentPerform(iterations: plugins.count) { index in
            registry.add(plugins[index])
        }
        
        let entries = registry.activeEntries
        XCTAssertEqual(entries.count, 100)
        XCTAssertEqual(Set(entries.map(\.info.name)).count, 100)
        XCTAssertEqual(entries.map(\.sequence), entries.map(\.sequence).sorted())
    }
    
    // MARK: - Helpers
    
    private func makeRegistry(capacity: Int? = nil) -> PluginRegistry<MockPlugin> {
        PluginRegistry(
            name: "test",
            identify: { $0.info },
            capacity: capacity,
            onRegister: { plugin in
                plugin.onRegisterAction?()
                plugin.record("onRegister")
            },
            onUnregister: { $0.record("onUnregister") }
        )
    }
}

class PrebidPluginInfoTests: XCTestCase {
    
    func testEquality_comparesNameAndVersion() {
        let info = PrebidPluginInfo(name: "plugin", version: "1.0")
        
        XCTAssertEqual(info, PrebidPluginInfo(name: "plugin", version: "1.0"))
        XCTAssertEqual(info.hash, PrebidPluginInfo(name: "plugin", version: "1.0").hash)
        XCTAssertNotEqual(info, PrebidPluginInfo(name: "plugin", version: "2.0"))
        XCTAssertNotEqual(info, PrebidPluginInfo(name: "other", version: "1.0"))
        XCTAssertFalse(info.isEqual("plugin/1.0"))
    }
    
    func testDescription() {
        XCTAssertEqual(PrebidPluginInfo(name: "plugin", version: "1.0").description, "plugin/1.0")
        XCTAssertEqual(PrebidPluginInfo(name: "plugin", version: "").description, "plugin")
    }
}
