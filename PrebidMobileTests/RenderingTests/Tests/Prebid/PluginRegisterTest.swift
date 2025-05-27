/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

extension PrebidMobilePluginRegister {
    
    func unregisterAllPlugins() {
        let plugins = getAllPlugins()
        for plugin in plugins {
            unregisterPlugin(plugin)
        }
    }
}

class PluginRegisterTest: XCTestCase {
    
    let prebidMobilePluginRegister = PrebidMobilePluginRegister.shared
    
    let plugin = MockPrebidMobilePluginRenderer(
        name: "MockPrebidMobilePluginRenderer",
        version: "1.0.0"
    )
    
    override func setUp() {
        super.setUp()
        prebidMobilePluginRegister.unregisterAllPlugins()
        prebidMobilePluginRegister.registerPlugin(plugin)
    }
    
    func testRegisterPlugin() {
        XCTAssertEqual(true, prebidMobilePluginRegister.containsPlugin(plugin))
        
        let plugins = prebidMobilePluginRegister.getAllPlugins()
        XCTAssertEqual(1, plugins.count)
    }
    
    func testUnregisterPlugin() {
        prebidMobilePluginRegister.unregisterPlugin(plugin)
        
        let containsPlugin = prebidMobilePluginRegister.containsPlugin(plugin)
        XCTAssertEqual(false, containsPlugin)
    }
    
    func testGetPluginForBidContainingSampleCustomRenderer() {
        let bid = Bid(
            bid: RawSampleCustomRendererBidFabricator.makeSampleCustomRendererBid(
                rendererName: "MockPrebidMobilePluginRenderer",
                rendererVersion: "1.0.0"
            )
        )
        
        let pluginRenderer = prebidMobilePluginRegister.getPluginForPreferredRenderer(
            bid: bid
        )
        
        XCTAssertEqual(pluginRenderer.name, plugin.name)
        XCTAssertEqual(pluginRenderer.version, plugin.version)
    }
}
