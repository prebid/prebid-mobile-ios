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

class VastCreativeLinearTest: XCTestCase {

    private func makeMediaFile(uri: String, type: String = "video/mp4", width: Int, height: Int) -> VastMediaFile {
        let mediaFile = VastMediaFile()
        mediaFile.mediaURI = uri
        mediaFile.type = type
        mediaFile.width = width
        mediaFile.height = height
        return mediaFile
    }

    private func makeCreative(_ mediaFiles: [VastMediaFile]) -> VastCreativeLinear {
        let creative = VastCreativeLinear()
        creative.mediaFiles = NSMutableArray(array: mediaFiles)
        return creative
    }

    func testBestMediaFilePicksLargestArea() {
        let creative = makeCreative([
            makeMediaFile(uri: "small", width: 320, height: 240),
            makeMediaFile(uri: "large", width: 1920, height: 1080),
            makeMediaFile(uri: "medium", width: 640, height: 480)
        ])

        XCTAssertEqual(creative.bestMediaFile()?.mediaURI, "large")
    }

    func testBestMediaFileIgnoresUnsupportedTypes() {
        let creative = makeCreative([
            makeMediaFile(uri: "unsupported", type: "video/x-flv", width: 1920, height: 1080),
            makeMediaFile(uri: "supported", width: 320, height: 240)
        ])

        XCTAssertEqual(creative.bestMediaFile()?.mediaURI, "supported")
    }

    func testBestMediaFileWithoutEligibleFilesIsNil() {
        XCTAssertNil(makeCreative([makeMediaFile(uri: "unsupported", type: "video/x-flv", width: 1, height: 1)]).bestMediaFile())
        XCTAssertNil(makeCreative([]).bestMediaFile())
    }

    // `width` and `height` come straight from the VAST XML. The ObjC multiplied NSIntegers, which wrap; `*` would trap.
    func testBestMediaFileDoesNotTrapOnOverflowingDimensions() {
        let creative = makeCreative([makeMediaFile(uri: "huge", width: 4_000_000_000, height: 4_000_000_000)])

        XCTAssertEqual(creative.bestMediaFile()?.mediaURI, "huge")
    }

    // Wrapped products decide the pick exactly as on master: 4e9 * 4e9 wraps negative, so the ordinary file wins.
    func testBestMediaFileComparesWrappedProducts() {
        let creative = makeCreative([
            makeMediaFile(uri: "huge", width: 4_000_000_000, height: 4_000_000_000),
            makeMediaFile(uri: "ordinary", width: 640, height: 480)
        ])

        XCTAssertEqual(creative.bestMediaFile()?.mediaURI, "ordinary")
    }

    func testBestMediaFileKeepsFirstOnEqualArea() {
        let creative = makeCreative([
            makeMediaFile(uri: "first", width: 640, height: 480),
            makeMediaFile(uri: "second", width: 480, height: 640)
        ])

        XCTAssertEqual(creative.bestMediaFile()?.mediaURI, "first")
    }
}
