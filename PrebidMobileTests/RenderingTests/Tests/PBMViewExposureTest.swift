/*   Copyright 2018-2021 Prebid.org, Inc.
 
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
import XCTest

// MARK: - Extensions

extension PBMViewExposure {
    convenience init(exposureFactor: Float, visibleRectangle: CGRect) {
        self.init(exposureFactor: exposureFactor,
                  visibleRectangle: visibleRectangle,
                  occlusionRectangles: nil as [NSValue]?)
    }
    convenience init(exposureFactor: Float, visibleRectangle: CGRect, occlusionRectangles: [CGRect]) {
        self.init(exposureFactor: exposureFactor,
                  visibleRectangle: visibleRectangle,
                  occlusionRectangles: occlusionRectangles.map(NSValue.init(cgRect:)))
    }
}

// MARK: - TestCase

class PBMViewExposureTest: XCTestCase {
    
    // MARK: - Single obstruction
    //
    //      0   10   20   30   40   50   60
    //     ][___][___][___][___][___][___][__
    //   0l +-----------+
    //    l |root       |
    //    l |   +----------------------+
    //    l |   |grandparent           |
    //  10L_|   |           +------+   |
    //    l |   |           |parent|   |
    //    l |   |           |      |   |
    //    l |   | +-----------+    |   |
    //    l |   | |obstruction|    |   |
    //  20L_|   +-|.........: |    |---+
    //    l |     |     :   : |    |
    //    l |     |     :   : |    |
    //    l |     |   +.......|-+  |
    //    l |     |   :view   | |  |
    //  30L_|     +-----------+ |  |
    //    l |         |         |  |
    //    l |         +---------+  |
    //    l |           |   |      |
    //    l |           |   +------+
    //  40L_|           |
    //    l +-----------+
    //
    // no clipping
    // +---------------------+-------+-------+-------+-----------+---------+-------+
    // |         view        | p-glob| p-loc |  size | obstructed|unexposed|exposed|
    // +---------------------+-------+-------+-------+-----+-----+---------+-------+
    // | *━┯ window          |  0, 0 |  0, 0 | 56x42 | N/A | N/A |   N/A   |  N/A  |
    // |   ┡━┯ root          |  1, 1 |  1, 1 | 24x40 |12,14|12x14|   7/40  | 33/40 |
    // |   │ ┗━┯ grandparent |  9, 5 |  8, 4 | 46x14 | 4,10|24x 4|  24/161 |137/161|
    // |   │   ┗━┯ parent    | 33, 9 | 24, 4 | 14x28 | 0, 6| 4x14|   1/7   |  6/7  |
    // |   │     ┗━━ view    | 21,25 |-12,16 | 20x 8 | 0, 0|16x 4|   2/5   |  3/5  |
    // |   ┗━━ obstruction   | 13,15 | 13,15 | 24x14 | N/A | N/A |   N/A   |  N/A  |
    // +---------------------+-------+-------+-------+-----+-----+---------+-------+
    //
    // unexposed = obstructed.size.area / size.area
    // exposed = 1 - unexposed
    //
    // XCTAssertEqual(1 - 24/161.0, 137/161.0) // <--- XCTAssertEqual failed: ("0.8509316770186335") is not equal to ("0.8509316770186336")
    //
    // => use exact values from 'exposed' to build PBMViewExposure, otherwise 'isEqual' might fail due to rounding errors
    //
    // root.clipToBounds = true
    //   => parent -- clipped out
    // +-------------+-------+-----+-----+-------+-----+-----+-------+-------+
    // |     view    |  size |  visible  | -area | obstructed| -area |exposed|
    // +-------------+-------+-----+-----+-------+-----+-----+-------+-------+
    // | grandparent | 46x14 | 0, 0|16x14|  8/23 | 4,10|12x 4| 12/161| 44/161|
    // | view        | 20x 8 | 0, 4| 4x 8|  1/5  | 0, 0| 0x 0|  1/10 |  1/10 |
    // +-------------+-------+-----+-----+-------+-----+-----+-------+-------+
    //
    // parent.clipToBounds = true
    // +-------------+-------+-----+-----+-------+-----+-----+-------+-------+
    // |     view    |  size |  visible  | -area | obstructed| -area |exposed|
    // +-------------+-------+-----+-----+-------+-----+-----+-------+-------+
    // | view        | 20x 8 |12, 0| 8x 8|  2/5  |12, 0| 4x 4|  1/10 |  3/10 |
    // +-------------+-------+-----+-----+-------+-----+-----+-------+-------+
    //
    // move obstruction to background
    // +-------------+-------+-----+-----+-------+
    // |     view    |  size |  visible  | -area |
    // +-------------+-------+-----+-----+-------+
    // | obstruction | 24x14 |12, 4| 8x 6|  1/7  |
    // +-------------+-------+-----+-----+-------+
    //
    func testSingleObstruction() {
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 560, height: 420))
        let root = UIView(frame: CGRect(x: 10, y: 10, width: 240, height: 400))
        let grandparent = UIView(frame: CGRect(x: 80, y: 40, width: 460, height: 140))
        let parent = UIView(frame: CGRect(x: 240, y: 40, width: 140, height: 280))
        let view = UIView(frame: CGRect(x: -120, y: 160, width: 200, height: 80))
        let obstruction = UIView(frame: CGRect(x: 130, y: 150, width: 240, height: 140))
        
        window.addSubview(root)
        root.addSubview(grandparent)
        grandparent.addSubview(parent)
        parent.addSubview(view)
        window.addSubview(obstruction)
        
        window.isHidden = false
        
        XCTAssertEqual(root.viewExposure, PBMViewExposure(exposureFactor: 33/40.0,
                                                          visibleRectangle: CGRect(x: 0, y: 0, width: 240, height: 400),
                                                          occlusionRectangles: [CGRect(x: 120, y: 140, width: 120, height: 140)]));
        XCTAssertEqual(grandparent.viewExposure, PBMViewExposure(exposureFactor: 137/161.0,
                                                                 visibleRectangle: CGRect(x: 0, y: 0, width: 460, height: 140),
                                                                 occlusionRectangles: [CGRect(x: 40, y: 100, width: 240, height: 40)]));
        XCTAssertEqual(parent.viewExposure, PBMViewExposure(exposureFactor: 6/7.0,
                                                            visibleRectangle: CGRect(x: 0, y: 0, width: 140, height: 280),
                                                            occlusionRectangles: [CGRect(x: 0, y: 60, width: 40, height: 140)]));
        XCTAssertEqual(view.viewExposure, PBMViewExposure(exposureFactor: 3/5.0,
                                                          visibleRectangle: CGRect(x: 0, y: 0, width: 200, height: 80),
                                                          occlusionRectangles: [CGRect(x: 0, y: 0, width: 160, height: 40)]));
        
        root.clipsToBounds = true
        // table 2
        
        XCTAssertEqual(grandparent.viewExposure, PBMViewExposure(exposureFactor: 44/161.0,
                                                                 visibleRectangle: CGRect(x: 0, y: 0, width: 160, height: 140),
                                                                 occlusionRectangles: [CGRect(x: 40, y: 100, width: 120, height: 40)]));
        XCTAssertEqual(parent.viewExposure, .zero);
        XCTAssertEqual(view.viewExposure, PBMViewExposure(exposureFactor: 1/10.0,
                                                          visibleRectangle: CGRect(x: 0, y: 40, width: 40, height: 40)));
        
        root.clipsToBounds = false
        parent.clipsToBounds = true
        // table 3
        
        XCTAssertEqual(view.viewExposure, PBMViewExposure(exposureFactor: 3/10.0,
                                                          visibleRectangle: CGRect(x: 120, y: 0, width: 80, height: 80),
                                                          occlusionRectangles: [CGRect(x: 120, y: 0, width: 40, height: 40)]));
        
        obstruction.removeFromSuperview()
        window.insertSubview(obstruction, belowSubview: root)
        
        parent.clipsToBounds = false
        // table 4
        
        XCTAssertEqual(obstruction.viewExposure, PBMViewExposure(exposureFactor: 1/7.0,
                                                                 visibleRectangle: CGRect(x: 120, y: 40, width: 80, height: 60)));
    }
    
    // MARK: - Composite hierarchy
    //
    //      0   10   20   30   40   50   60
    //     ][___][___][___][___][___][___][__
    //   0l +-----------------------------+
    //    l |parent   +-----------------+ |
    //    l |         |brother          | |
    //    l |  +------|.............+   | |
    //  10L_|  |adView|             :   | |
    //    l |  |      +-----------------+ |
    //    l |  | +-----+            |     |
    //    l |  | |X-btn|            |     |
    //    l |  | +-----+  +-----------+   |
    //  20L_|  |          |uncle    : |   |
    //    l |  |          |         : |   |
    //    l |  |          |         : |   |
    //    l |  |          +-----------+   |
    //    l |  |                    |     |
    //  30L_|+--------------------------+ |
    //    l ||aunt    +---------+   :   | |
    //    l || :      |cousin   |   :   | |
    //    l || +......|.........|...+   | |
    //    l ||        +---------+       | |
    //  40L_|+--------------------------+ |
    //    l +-----------------------------+
    //
    // no clipping
    // +---------------------+-------+-------+-------+-----------+-----------+-----------+---------+-----------+---------+
    // |         view        | p-glob| p-loc |  size | obstructed| obstructed| obstructed|unexposed|  visible  | exposed |
    // +---------------------+-------+-------+-------+-----+-----+-----+-----+-----+-----+---------+-----+-----+---------+
    // | *━┯ window          |  0, 0 |  0, 0 | 62x42 |     :     |     :     |     :     |   N/A   |    N/A    |   N/A   |
    // |   ┡━┯ parent        |  1, 1 |  1, 1 | 60x40 | 2,28:54x10|28,16:24x 8|     :     | 732/2400| 0, 0:60x40|1668/2400|
    // |   │ ┡━━ adView      |  7, 7 |  6, 6 | 42x28 |22,10:20x 8|14, 0:28x 4| 4, 6:12x 4| 320/1176| 0, 0:42x22| 604/1176|
    // |   │ ┗━━ brother     | 21, 3 | 20, 2 | 36x 8 |     :     |     :     |     :     |   N/A   | 0, 0:36x 8|    1    |
    // |   │ ┗━━ X-btn       | 11,13 | 10,12 | 12x 4 |     :     |     :     |     :     |   N/A   | 0, 0:12x 4|    1    |
    // |   ┡━━ uncle         | 29,17 | 29,17 | 24x 8 |     :     |     :     |     :     |   N/A   | 0, 0:24x 8|    1    |
    // |   ┗━┯ aunt          |  3,29 |  3,29 | 54x10 |     :     |     :     |     :     |   N/A   | 0, 0:54x10|    1    |
    // |     ┗━━ cousin      | 21,31 | 18, 2 | 20x 6 |     :     |     :     |     :     |   N/A   | 0, 0:20x 6|    1    |
    // +---------------------+-------+-------+-------+-----+-----+-----+-----+-----+-----+---------+-----+-----+---------+
    //
    func testMultipleObstructions() {
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 620, height: 420))
        let parent = UIView(frame: CGRect(x: 10, y: 10, width: 600, height: 400))
        let adView = UIView(frame: CGRect(x: 60, y: 60, width: 420, height: 280))
        let brother = UIView(frame: CGRect(x: 200, y: 20, width: 360, height: 80))
        let xBtn = UIView(frame: CGRect(x: 100, y: 120, width: 120, height: 40))
        let uncle = UIView(frame: CGRect(x: 290, y: 170, width: 240, height: 80))
        let aunt = UIView(frame: CGRect(x: 30, y: 290, width: 540, height: 100))
        let cousin = UIView(frame: CGRect(x: 180, y: 20, width: 200, height: 60))
        
        window.addSubview(parent)
        parent.addSubview(adView)
        parent.addSubview(brother)
        parent.addSubview(xBtn)
        window.addSubview(uncle)
        window.addSubview(aunt)
        aunt.addSubview(cousin)
        
        window.isHidden = false
        
        XCTAssertEqual(parent.viewExposure, PBMViewExposure(exposureFactor: 1668/2400.0,
                                                            visibleRectangle: CGRect(x: 0, y: 0, width: 600, height: 400),
                                                            occlusionRectangles: [CGRect(x: 20, y: 280, width: 540, height: 100),
                                                                                  CGRect(x: 280, y: 160, width: 240, height: 80)]));
        
        XCTAssertEqual(adView.viewExposure, PBMViewExposure(exposureFactor: 604/1176.0,
                                                            visibleRectangle: CGRect(x: 0, y: 0, width: 420, height: 220),
                                                            occlusionRectangles: [CGRect(x: 220, y: 100, width: 200, height: 80),
                                                                                  CGRect(x: 140, y: 0, width: 280, height: 40),
                                                                                  CGRect(x: 40, y: 60, width: 120, height: 40)]));
        
        XCTAssertEqual(brother.viewExposure, PBMViewExposure(exposureFactor: 1,
                                                             visibleRectangle: CGRect(x: 0, y: 0, width: 360, height: 80)));
        
        XCTAssertEqual(xBtn.viewExposure, PBMViewExposure(exposureFactor: 1,
                                                          visibleRectangle: CGRect(x: 0, y: 0, width: 120, height: 40)));
        
        XCTAssertEqual(uncle.viewExposure, PBMViewExposure(exposureFactor: 1,
                                                           visibleRectangle: CGRect(x: 0, y: 0, width: 240, height: 80)));
        
        XCTAssertEqual(aunt.viewExposure, PBMViewExposure(exposureFactor: 1,
                                                          visibleRectangle: CGRect(x: 0, y: 0, width: 540, height: 100)));
        
        XCTAssertEqual(cousin.viewExposure, PBMViewExposure(exposureFactor: 1,
                                                            visibleRectangle: CGRect(x: 0, y: 0, width: 200, height: 60)));
    }
}
