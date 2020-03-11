/*   Copyright 2018-2019 Prebid.org, Inc.

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

class VideoBaseAdUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testVideoParameters() {
        
        let videoParameters = VideoBaseAdUnit.VideoParameters()
        videoParameters.api = [1, 2]
        videoParameters.maxBitrate = 1500
        videoParameters.minBitrate = 300
        videoParameters.maxDuration = 30
        videoParameters.minDuration = 5
        videoParameters.mimes = ["video/x-flv", "video/mp4"]
        videoParameters.playbackMethod = [1, 3]
        videoParameters.protocols = [2, 3]
        videoParameters.startDelay = 0
        
        XCTAssertEqual(2, videoParameters.api!.count)
        XCTAssert(videoParameters.api!.contains(1) && videoParameters.api!.contains(2))
        XCTAssertEqual(1500, videoParameters.maxBitrate)
        XCTAssertEqual(300, videoParameters.minBitrate)
        XCTAssertEqual(30, videoParameters.maxDuration)
        XCTAssertEqual(5, videoParameters.minDuration)
        XCTAssertEqual(2, videoParameters.mimes!.count)
        XCTAssert(videoParameters.mimes!.contains("video/x-flv") && videoParameters.mimes!.contains("video/mp4"))
        XCTAssertEqual(2, videoParameters.playbackMethod!.count)
        XCTAssert(videoParameters.playbackMethod!.contains(1) && videoParameters.playbackMethod!.contains(3))
        XCTAssertEqual(2, videoParameters.protocols!.count)
        XCTAssert(videoParameters.protocols!.contains(2) && videoParameters.protocols!.contains(3))
        XCTAssertEqual(0, videoParameters.startDelay)
    }

}
