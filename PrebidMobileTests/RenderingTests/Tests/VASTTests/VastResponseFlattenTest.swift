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

@_spi(PBMInternal) @testable import PrebidMobile

// Pins the error `-[PBMVastResponse flattenResponseAndReturnError:]` reported on master for failed wrapper chains.
// The ObjC kept a nested failure in its out-param, went on with the remaining ads and failed at the end, so
// "No Inline Ads found" wins over a nested error, and a nested error wins over a successful sibling.
class VastResponseFlattenTest: XCTestCase {

    private let noNextResponse = "Server error: No nextResponse on a wrapper"
    private let noInlineAds = "SDK internal error: No Inline Ads found during wrapper flattening"

    private func makeResponse(ads: [VastAbstractAd]) -> VastResponse {
        let response = VastResponse()
        response.vastAbstractAds = NSMutableArray(array: ads)
        return response
    }

    private func makeWrapper(resolvingTo nextResponse: VastResponse?) -> VastWrapperAd {
        let wrapper = VastWrapperAd()
        wrapper.vastResponse = nextResponse
        return wrapper
    }

    private func failure(of response: VastResponse) -> String? {
        do {
            _ = try response.flattenResponse()
            return nil
        } catch {
            return (error as? PBMError)?.message ?? "\(error)"
        }
    }

    // Root, then wrapper E, whose response holds wrapper F1 (resolved to an inline ad) and wrapper F2 (no response yet).
    // Master: the nested failure is remembered, E ends with no inline ads of its own to add, so the root reports "No Inline Ads".
    func testNestedWrapperWithoutResponseAfterResolvedSibling() {
        let resolved = makeWrapper(resolvingTo: makeResponse(ads: [VastInlineAd()]))
        let unresolved = makeWrapper(resolvingTo: nil)
        let wrapperE = makeWrapper(resolvingTo: makeResponse(ads: [resolved, unresolved]))
        let root = makeResponse(ads: [wrapperE])

        XCTAssertEqual(failure(of: root), noInlineAds)
    }

    // Same tree with a sibling inline ad at the root: the root has one ad to return, so the remembered nested error is reported.
    func testNestedWrapperWithoutResponseWithInlineSiblingAtRoot() {
        let resolved = makeWrapper(resolvingTo: makeResponse(ads: [VastInlineAd()]))
        let unresolved = makeWrapper(resolvingTo: nil)
        let wrapperE = makeWrapper(resolvingTo: makeResponse(ads: [resolved, unresolved]))
        let root = makeResponse(ads: [VastInlineAd(), wrapperE])

        XCTAssertEqual(failure(of: root), noNextResponse)
    }

    func testWrapperWithoutResponseReportsNoNextResponse() {
        let root = makeResponse(ads: [makeWrapper(resolvingTo: nil)])

        XCTAssertEqual(failure(of: root), noNextResponse)
    }

    func testResolvedWrapperFlattensToItsInlineAd() throws {
        let inlineAd = VastInlineAd()
        let root = makeResponse(ads: [makeWrapper(resolvingTo: makeResponse(ads: [inlineAd]))])

        let ads = try root.flattenResponse()

        XCTAssertEqual(ads.count, 1)
        XCTAssertTrue(ads.first === inlineAd)
    }

    func testEmptyResponseReportsNoInlineAds() {
        XCTAssertEqual(failure(of: makeResponse(ads: [])), noInlineAds)
    }
}
