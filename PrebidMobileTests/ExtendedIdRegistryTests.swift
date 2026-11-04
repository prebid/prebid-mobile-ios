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

final class ExtendedIdRegistryTests: XCTestCase {

    private var registry: ExtendedIdRegistry!

    override func setUp() {
        super.setUp()
        unregisterAllProviders()
        registry = ExtendedIdRegistry()
    }

    override func tearDown() {
        unregisterAllProviders()
        registry = nil
        super.tearDown()
    }

    // MARK: - Providers

    func testRegisteredProviderIdsAreIncluded() {
        let userId = createUserId(source: "source1", id: "id1")

        register(MockExtendedIdProvider(name: "test", extendedIds: [userId]))

        XCTAssertEqual(sources(registry.getAllExtendedIds()), ["source1"])
        XCTAssertTrue(registry.getAllExtendedIds().first === userId)
    }

    func testGetAllExtendedIdsCallsProviderOnEveryRequest() {
        let provider = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "source1", id: "id1")])
        register(provider)

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])

        provider.extendedIds = [createUserId(source: "source1", id: "id2")]

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id2"])
        XCTAssertEqual(provider.getExtendedIdsCount, 2)
    }

    func testRegisterCallsOnRegister() {
        let provider = MockExtendedIdProvider(name: "test")

        register(provider)

        XCTAssertEqual(provider.onRegisterCount, 1)
        XCTAssertTrue(Prebid.contains(provider, as: .extendedIds))
    }

    func testProviderIsNotActiveUntilOnRegisterReturns() {
        let provider = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "source1", id: "id1")])
        let registry = self.registry!
        var idsDuringOnRegister: [ExtendedId]?
        var isActiveDuringOnRegister: Bool?
        provider.onRegisterHandler = { [unowned provider] in
            idsDuringOnRegister = registry.getAllExtendedIds()
            isActiveDuringOnRegister = Prebid.contains(provider, as: .extendedIds)
        }

        register(provider)

        XCTAssertEqual(idsDuringOnRegister?.count, 0)
        XCTAssertEqual(isActiveDuringOnRegister, false)
        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])
        XCTAssertTrue(Prebid.contains(provider, as: .extendedIds))
    }

    func testDuplicateProviderInfoIsIgnored() {
        let provider1 = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "s1", id: "id1")])
        let provider2 = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "s2", id: "id2")])

        register(provider1)
        register(provider2)

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])
        XCTAssertEqual(provider2.onRegisterCount, 0)
    }

    func testProvidersWithSameNameAndDifferentVersionsAreDistinct() {
        register(MockExtendedIdProvider(name: "test", version: "1.0", extendedIds: [createUserId(source: "s1", id: "id1")]))
        register(MockExtendedIdProvider(name: "test", version: "2.0", extendedIds: [createUserId(source: "s2", id: "id2")]))

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1", "id2"])
    }

    func testUnregisterCallsOnUnregisterAndDropsItsIds() {
        let provider = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "source1", id: "id1")])
        register(provider)

        Prebid.unregister(provider, as: .extendedIds)

        XCTAssertEqual(provider.onUnregisterCount, 1)
        XCTAssertFalse(Prebid.contains(provider, as: .extendedIds))
        XCTAssertTrue(registry.getAllExtendedIds().isEmpty)
    }

    func testUnregisterUnknownProviderIsNoOp() {
        let provider = MockExtendedIdProvider(name: "test")

        Prebid.unregister(provider, as: .extendedIds)

        XCTAssertEqual(provider.onUnregisterCount, 0)
    }

    func testUnregisterProviderWithEqualInfoRemovesRegisteredInstance() {
        let registered = MockExtendedIdProvider(name: "test")
        let other = MockExtendedIdProvider(name: "test")
        register(registered)

        Prebid.unregister(other, as: .extendedIds)

        XCTAssertEqual(registered.onUnregisterCount, 1)
        XCTAssertEqual(other.onUnregisterCount, 0)
        XCTAssertFalse(Prebid.contains(registered, as: .extendedIds))
    }

    func testUnregisterDoesNotAffectOtherProviders() {
        let provider1 = MockExtendedIdProvider(name: "p1", extendedIds: [createUserId(source: "source1", id: "id1")])
        register(provider1)
        register(MockExtendedIdProvider(name: "p2", extendedIds: [createUserId(source: "source2", id: "id2")]))

        Prebid.unregister(provider1, as: .extendedIds)

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id2"])
    }

    func testProviderWithoutLifecycleMethods() {
        let provider = MockMinimalExtendedIdProvider(name: "minimal", extendedIds: [createUserId(source: "source1", id: "id1")])

        register(provider)
        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])

        Prebid.unregister(provider, as: .extendedIds)
        XCTAssertTrue(registry.getAllExtendedIds().isEmpty)
    }

    func testObjectWithoutProviderProtocolIsNotRegistered() {
        let object = NSObject()

        Prebid.register(object, as: .extendedIds)

        XCTAssertFalse(Prebid.contains(object, as: .extendedIds))
        XCTAssertTrue(Registries.extendedIds.typed.active.isEmpty)
    }

    // MARK: - Order and sources

    func testStaticIdsComeFirstThenSharedIdThenProvidersInRegistrationOrder() {
        register(MockExtendedIdProvider(name: "p2", extendedIds: [createUserId(source: "p2.com", id: "id2")]))
        register(MockExtendedIdProvider(name: "p1", extendedIds: [createUserId(source: "p1.com", id: "id1")]))
        registry.staticProvider.addUserId(createUserId(source: "static.com", id: "id0"))

        let extendedIds = registry.getAllExtendedIds(sharedId: createUserId(source: "pubcid.org", id: "shared"))

        XCTAssertEqual(sources(extendedIds), ["static.com", "pubcid.org", "p2.com", "p1.com"])
    }

    func testProviderIdWithSourceAlreadyPresentIsSkipped() {
        let logToFile = LogToFileLock()
        registry.staticProvider.addUserId(createUserId(source: "static.com", id: "static"))
        register(MockExtendedIdProvider(name: "first", extendedIds: [
            createUserId(source: "static.com", id: "first-static"),
            createUserId(source: "pubcid.org", id: "first-shared"),
            createUserId(source: "vendor.com", id: "first-vendor"),
        ]))
        register(MockExtendedIdProvider(name: "second", extendedIds: [
            createUserId(source: "vendor.com", id: "second-vendor"),
            createUserId(source: "second.com", id: "second"),
        ]))

        let extendedIds = registry.getAllExtendedIds(sharedId: createUserId(source: "pubcid.org", id: "shared"))

        XCTAssertEqual(ids(extendedIds), ["static", "shared", "first-vendor", "second"])
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains("Skipping the ID from source static.com provided by first/1.0"))
        XCTAssertTrue(log.contains("Skipping the ID from source vendor.com provided by second/1.0"))

        withExtendedLifetime(logToFile) {}
    }

    func testStaticIdsAndSharedIdWithTheSameSourceAreAllKept() {
        registry.staticProvider.setUserIds([
            createUserId(source: "source1", id: "id1"),
            createUserId(source: "source1", id: "id2"),
            createUserId(source: "pubcid.org", id: "id3"),
        ])

        let extendedIds = registry.getAllExtendedIds(sharedId: createUserId(source: "pubcid.org", id: "shared"))

        XCTAssertEqual(ids(extendedIds), ["id1", "id2", "id3", "shared"])
    }

    // MARK: - Static IDs

    func testAddUserIdReplacesIdsWithSameSource() {
        registry.staticProvider.setUserIds([
            createUserId(source: "source1", id: "id1"),
            createUserId(source: "source2", id: "id2"),
            createUserId(source: "source1", id: "id3"),
        ])

        registry.staticProvider.addUserId(createUserId(source: "source1", id: "id4"))

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id2", "id4"])
    }

    func testRemoveUserIdRemovesOnlyThatSource() {
        registry.staticProvider.setUserIds([
            createUserId(source: "source1", id: "id1"),
            createUserId(source: "source2", id: "id2"),
        ])

        registry.staticProvider.removeUserId(source: "source1")

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id2"])
    }

    func testSetUserIdsDoesNotAffectProviderIds() {
        register(MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "provider.com", id: "id1")]))
        registry.staticProvider.setUserIds([createUserId(source: "static.com", id: "id2")])

        registry.staticProvider.setUserIds([])

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])
    }

    // MARK: - ExtendedIdProviderInfo

    func testProviderInfoEquality() {
        let info = ExtendedIdProviderInfo(name: "test", version: "1.0")

        XCTAssertEqual(info, ExtendedIdProviderInfo(name: "test", version: "1.0"))
        XCTAssertEqual(info.hash, ExtendedIdProviderInfo(name: "test", version: "1.0").hash)
        XCTAssertNotEqual(info, ExtendedIdProviderInfo(name: "test", version: "2.0"))
        XCTAssertNotEqual(info, ExtendedIdProviderInfo(name: "other", version: "1.0"))
        XCTAssertEqual(info.description, "test/1.0")
    }

    // MARK: - Helpers

    private func register(_ provider: ExtendedIdProvider) {
        Prebid.register(provider, as: .extendedIds)
    }

    private func unregisterAllProviders() {
        let providers = Registries.extendedIds.typed
        providers.active.forEach { providers.remove($0) }
    }

    private func createUserId(source: String, id: String) -> ExternalUserId {
        ExternalUserId(source: source, uids: [UserUniqueID(uniqueId: id, aType: 1)])
    }

    private func sources(_ extendedIds: [ExtendedId]) -> [String] {
        extendedIds.map { $0.source }
    }

    private func ids(_ extendedIds: [ExtendedId]) -> [String] {
        extendedIds.compactMap { ($0 as? ExternalUserId)?.uids.first?.uniqueId }
    }
}
