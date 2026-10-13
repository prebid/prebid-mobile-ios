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
        registry = ExtendedIdRegistry()
    }

    override func tearDown() {
        registry.clearProviders()
        registry = nil
        super.tearDown()
    }

    // MARK: - Providers

    func testAddProviderIncludesItsIds() {
        let userId = createUserId(source: "source1", id: "id1")

        registry.addProvider(MockExtendedIdProvider(name: "test", extendedIds: [userId]))

        XCTAssertEqual(sources(registry.getAllExtendedIds()), ["source1"])
        XCTAssertTrue(registry.getAllExtendedIds().first === userId)
    }

    func testGetAllExtendedIdsCallsProviderOnEveryRequest() {
        let provider = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "source1", id: "id1")])
        registry.addProvider(provider)

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])

        provider.extendedIds = [createUserId(source: "source1", id: "id2")]

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id2"])
        XCTAssertEqual(provider.getExtendedIdsCount, 2)
    }

    func testAddProviderCallsOnRegister() {
        let provider = MockExtendedIdProvider(name: "test")

        registry.addProvider(provider)

        XCTAssertEqual(provider.onRegisterCount, 1)
        XCTAssertTrue(registry.hasProvider(provider))
    }

    func testProviderIdsAreCollectedOnlyAfterOnRegisterReturns() {
        let provider = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "source1", id: "id1")])
        let registry = self.registry!
        var idsDuringOnRegister: [ExtendedId]?
        var isRegisteredDuringOnRegister: Bool?
        provider.onRegisterHandler = { [unowned provider] in
            idsDuringOnRegister = registry.getAllExtendedIds()
            isRegisteredDuringOnRegister = registry.hasProvider(provider)
        }

        registry.addProvider(provider)

        XCTAssertEqual(idsDuringOnRegister?.count, 0)
        XCTAssertEqual(isRegisteredDuringOnRegister, true)
        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])
    }

    func testDuplicateProviderInfoIsIgnored() {
        let provider1 = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "s1", id: "id1")])
        let provider2 = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "s2", id: "id2")])

        registry.addProvider(provider1)
        registry.addProvider(provider2)

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])
        XCTAssertEqual(provider2.onRegisterCount, 0)
    }

    func testProvidersWithSameNameAndDifferentVersionsAreDistinct() {
        registry.addProvider(MockExtendedIdProvider(name: "test", version: "1.0", extendedIds: [createUserId(source: "s1", id: "id1")]))
        registry.addProvider(MockExtendedIdProvider(name: "test", version: "2.0", extendedIds: [createUserId(source: "s1", id: "id2")]))

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1", "id2"])
    }

    func testRemoveProviderCallsOnUnregisterAndDropsItsIds() {
        let provider = MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "source1", id: "id1")])
        registry.addProvider(provider)

        registry.removeProvider(provider)

        XCTAssertEqual(provider.onUnregisterCount, 1)
        XCTAssertFalse(registry.hasProvider(provider))
        XCTAssertTrue(registry.getAllExtendedIds().isEmpty)
    }

    func testRemoveUnknownProviderIsNoOp() {
        let provider = MockExtendedIdProvider(name: "test")

        registry.removeProvider(provider)

        XCTAssertEqual(provider.onUnregisterCount, 0)
    }

    func testRemoveProviderWithEqualInfoRemovesRegisteredInstance() {
        let registered = MockExtendedIdProvider(name: "test")
        let other = MockExtendedIdProvider(name: "test")
        registry.addProvider(registered)

        registry.removeProvider(other)

        XCTAssertEqual(registered.onUnregisterCount, 1)
        XCTAssertEqual(other.onUnregisterCount, 0)
        XCTAssertFalse(registry.hasProvider(registered))
    }

    func testRemoveProviderDoesNotAffectOtherProviders() {
        let provider1 = MockExtendedIdProvider(name: "p1", extendedIds: [createUserId(source: "source1", id: "id1")])
        registry.addProvider(provider1)
        registry.addProvider(MockExtendedIdProvider(name: "p2", extendedIds: [createUserId(source: "source2", id: "id2")]))

        registry.removeProvider(provider1)

        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id2"])
    }

    func testProviderWithoutLifecycleMethods() {
        let provider = MockMinimalExtendedIdProvider(name: "minimal", extendedIds: [createUserId(source: "source1", id: "id1")])

        registry.addProvider(provider)
        XCTAssertEqual(ids(registry.getAllExtendedIds()), ["id1"])

        registry.removeProvider(provider)
        XCTAssertTrue(registry.getAllExtendedIds().isEmpty)
    }

    func testClearProvidersUnregistersAllAndClearsStaticIds() {
        let provider1 = MockExtendedIdProvider(name: "p1", extendedIds: [createUserId(source: "source1", id: "id1")])
        let provider2 = MockExtendedIdProvider(name: "p2", extendedIds: [createUserId(source: "source2", id: "id2")])
        registry.addProvider(provider1)
        registry.addProvider(provider2)
        registry.staticProvider.addUserId(createUserId(source: "static", id: "id3"))

        registry.clearProviders()

        XCTAssertEqual(provider1.onUnregisterCount, 1)
        XCTAssertEqual(provider2.onUnregisterCount, 1)
        XCTAssertTrue(registry.getAllExtendedIds().isEmpty)
    }

    // MARK: - Static IDs

    func testStaticIdsComeFirstThenProvidersInRegistrationOrder() {
        registry.addProvider(MockExtendedIdProvider(name: "p2", extendedIds: [createUserId(source: "p2.com", id: "id2")]))
        registry.addProvider(MockExtendedIdProvider(name: "p1", extendedIds: [createUserId(source: "p1.com", id: "id1")]))
        registry.staticProvider.addUserId(createUserId(source: "static.com", id: "id0"))

        XCTAssertEqual(sources(registry.getAllExtendedIds()), ["static.com", "p2.com", "p1.com"])
    }

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
        registry.addProvider(MockExtendedIdProvider(name: "test", extendedIds: [createUserId(source: "provider.com", id: "id1")]))
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
