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

private final class EventDelegateRenderer: MockPrebidMobilePluginRenderer {
    
    var onRegisterEventDelegate: ((String) -> Void)?
    var onUnregisterEventDelegate: ((String) -> Void)?
    
    @objc func registerEventDelegate(pluginEventDelegate: PluginEventDelegate, adUnitConfigFingerprint: String) {
        onRegisterEventDelegate?(adUnitConfigFingerprint)
    }
    
    @objc func unregisterEventDelegate(pluginEventDelegate: PluginEventDelegate, adUnitConfigFingerprint: String) {
        onUnregisterEventDelegate?(adUnitConfigFingerprint)
    }
}

class PluginRegistrationTests: XCTestCase {
    
    private let register = PrebidMobilePluginRegister.shared
    private var savedRenderers = [PrebidMobilePluginRenderer]()
    
    override func setUp() {
        super.setUp()
        
        savedRenderers = register.getAllPlugins()
        savedRenderers.forEach(register.unregisterPlugin)
    }
    
    override func tearDown() {
        register.getAllPlugins().forEach(register.unregisterPlugin)
        savedRenderers.forEach(register.registerPlugin)
        
        super.tearDown()
    }
    
    func testRendererCapability() {
        XCTAssertEqual(PluginCapability.renderer.name, "renderer")
        XCTAssertEqual(PluginCapability.renderer.description, "renderer")
        XCTAssertTrue(PluginCapability.renderer === PluginCapability.renderer)
    }
    
    func testRegister_renderer_isAvailableToTheSDK() {
        let renderer = MockPrebidMobilePluginRenderer(name: "Vendor", version: "1.0")
        
        Prebid.register(renderer, as: .renderer)
        
        XCTAssertTrue(Prebid.contains(renderer, as: .renderer))
        XCTAssertTrue(Prebid.containsPluginRenderer(renderer))
        XCTAssertTrue(register.containsPlugin(renderer))
        XCTAssertTrue(register.getAllPlugins().first === renderer)
    }
    
    func testRegister_objectWithoutRendererProtocol_isNotRegistered() {
        let object = NSObject()
        
        Prebid.register(object, as: .renderer)
        
        XCTAssertFalse(Prebid.contains(object, as: .renderer))
        XCTAssertTrue(register.getAllPlugins().isEmpty)
        
        // Ignored too, rather than failing.
        Prebid.unregister(object, as: .renderer)
    }
    
    func testRegister_sameNameOtherVersion_keepsFirstRenderer() {
        let first = MockPrebidMobilePluginRenderer(name: "Vendor", version: "1.0")
        let second = MockPrebidMobilePluginRenderer(name: "Vendor", version: "2.0")
        
        Prebid.register(first, as: .renderer)
        Prebid.register(second, as: .renderer)
        
        XCTAssertEqual(register.getAllPlugins().count, 1)
        XCTAssertTrue(register.getAllPlugins().first === first)
        
        // `contains(_:as:)` matches by name, `containsPluginRenderer(_:)` by instance.
        XCTAssertTrue(Prebid.contains(second, as: .renderer))
        XCTAssertFalse(Prebid.containsPluginRenderer(second))
    }
    
    func testUnregister_removesRendererWithSameName() {
        let registered = MockPrebidMobilePluginRenderer(name: "Vendor", version: "1.0")
        let other = MockPrebidMobilePluginRenderer(name: "Vendor", version: "2.0")
        Prebid.register(registered, as: .renderer)
        
        Prebid.unregister(other, as: .renderer)
        
        XCTAssertFalse(Prebid.containsPluginRenderer(registered))
        XCTAssertTrue(register.getAllPlugins().isEmpty)
    }
    
    func testRegisterPluginRenderer_usesRendererCapability() {
        let renderer = MockPrebidMobilePluginRenderer(name: "Vendor", version: "1.0")
        
        Prebid.registerPluginRenderer(renderer)
        
        XCTAssertTrue(Prebid.contains(renderer, as: .renderer))
        
        Prebid.unregisterPluginRenderer(renderer)
        
        XCTAssertFalse(Prebid.contains(renderer, as: .renderer))
        XCTAssertFalse(Prebid.containsPluginRenderer(renderer))
    }
    
    func testGetAllPlugins_returnsRenderersInRegistrationOrder() {
        let names = ["c", "a", "d", "b"]
        
        names.forEach {
            Prebid.register(MockPrebidMobilePluginRenderer(name: $0, version: "1.0"), as: .renderer)
        }
        
        XCTAssertEqual(register.getAllPlugins().map(\.name), names)
        XCTAssertEqual(register.getAllPluginsJSONRepresentation().compactMap { $0["name"] as? String }, names)
    }
    
    func testGetAllPluginsJSONRepresentation_excludesSDKRenderer() {
        Prebid.register(PrebidRenderer(), as: .renderer)
        Prebid.register(MockPrebidMobilePluginRenderer(name: "Vendor", version: "1.0"), as: .renderer)
        
        XCTAssertEqual(register.getAllPluginsJSONRepresentation().compactMap { $0["name"] as? String }, ["Vendor"])
        XCTAssertEqual(register.sdkRenderer.name, PREBID_MOBILE_RENDERER_NAME)
    }
    
    func testEventDelegates_reachActiveRenderers() {
        let renderer = EventDelegateRenderer(name: "Vendor", version: "1.0")
        Prebid.register(renderer, as: .renderer)
        
        let registered = expectation(description: "registerEventDelegate")
        let unregistered = expectation(description: "unregisterEventDelegate")
        renderer.onRegisterEventDelegate = { fingerprint in
            XCTAssertEqual(fingerprint, "fingerprint")
            XCTAssertFalse(Thread.isMainThread)
            registered.fulfill()
        }
        renderer.onUnregisterEventDelegate = { fingerprint in
            XCTAssertEqual(fingerprint, "fingerprint")
            unregistered.fulfill()
        }
        
        let delegate = DefaultPluginEventDelegate()
        register.registerEventDelegate(delegate, adUnitConfigFingerprint: "fingerprint")
        register.unregisterEventDelegate(delegate, adUnitConfigFingerprint: "fingerprint")
        
        wait(for: [registered, unregistered], timeout: 5, enforceOrder: true)
    }
}
