//
//  PluginRegisterTest.swift
//  PrebidMobileTests
//
//  Created by Richard Dépierre on 24/07/2024.
//  Copyright © 2024 AppNexus. All rights reserved.
//

import XCTest

@testable import PrebidMobile
import TestUtils

class PluginRegisterTest: XCTestCase {
    let prebidMobilePluginRegister = PrebidMobilePluginRegister.shared
    let plugin = SampleCustomRenderer()
    
    override func setUp() {
        super.setUp()
        unregisterAllPlugins()
        prebidMobilePluginRegister.registerPlugin(plugin)
    }

    func unregisterAllPlugins() {
        let plugins = prebidMobilePluginRegister.getAllPlugins()
        for plugin in plugins {
            prebidMobilePluginRegister.unregisterPlugin(plugin)
        }
    }
    
    func testRegisterPlugin() {
        let containsPlugin = prebidMobilePluginRegister.containsPlugin(plugin)
        let plugins = prebidMobilePluginRegister.getAllPlugins()
        XCTAssertEqual(true, containsPlugin)
        XCTAssertEqual(2, plugins.count)
    }

    func testUnregisterPlugin() {
        prebidMobilePluginRegister.unregisterPlugin(plugin)
        
        let containsPlugin = prebidMobilePluginRegister.containsPlugin(plugin)
        XCTAssertEqual(false, containsPlugin)
    }
    
    func testGetPluginForBidContainingSampleCustomRenderer() {
        let bidResponse = Bid(
            bid: RawSampleCustomRendererBidFabricator.makeSampleCustomRendererBid(
                rendererName: "SampleCustomRenderer",
                rendererVersion: "1.0.0"
            )
        )
        
        let pluginRenderer = prebidMobilePluginRegister.getPluginForPreferredRenderer(
            bid: bidResponse
        )
        XCTAssertEqual(pluginRenderer.name, plugin.name)
        XCTAssertEqual(pluginRenderer.version, plugin.version)
    }
    
    func testGetRTBListOfRenderersFor() {
        let adUnitConfigBanner = AdUnitConfig(
            configId: "configID",
            size: CGSize(
                width: 300,
                height: 250
            )
        )
        let adUnitConfigError = AdUnitConfig(configId: "configID")
        
        var renderers = prebidMobilePluginRegister.getRTBListOfRenderersFor(for: adUnitConfigBanner)
        XCTAssertEqual(1, renderers.count)
        
        renderers = prebidMobilePluginRegister.getRTBListOfRenderersFor(for: adUnitConfigError)
        XCTAssertEqual(1, renderers.count)
    }
}
