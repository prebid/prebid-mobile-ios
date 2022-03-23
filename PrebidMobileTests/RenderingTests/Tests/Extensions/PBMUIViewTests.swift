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

import XCTest

@testable import PrebidMobile

class PBMUIViewTests: XCTestCase {
    
    // MARK: - Constants
    
    private let testX: CGFloat      = 1
    private let testY: CGFloat      = 3
    private let testWidth: CGFloat  = 70
    private let testHeight: CGFloat = 30
    
    private let superview = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
    private let testView = UIView()
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testAddConstraintWithoutSuperview() {
        
        superview.addSubview(testView)
        
        XCTAssertTrue(superview.constraints.isEmpty)
        XCTAssertTrue(testView.translatesAutoresizingMaskIntoConstraints)
        
        testView.removeFromSuperview()
        
        // Run methods
        
        testView.PBMAddFillSuperviewConstraints()
        
        let testRect = CGRect(x: testX, y: testY, width: testWidth, height: testHeight)
        testView.PBMAddConstraintsFromCGRect(testRect)
        
        let viewSize = CGSize(width: 120, height: 110)
        let marginSize = CGSize(width: testWidth, height: testHeight)
        testView.PBMAddBottomRightConstraints(viewSize: viewSize, marginSize: marginSize)
        testView.PBMAddTopRightConstraints(viewSize: viewSize, marginSize: marginSize)
        testView.PBMAddTopLeftConstraints(viewSize: viewSize, marginSize: marginSize)
        
        testView.PBMAddCropAndCenterConstraints(initialWidth: testWidth, initialHeight: testHeight)
        
        // This property should not change
        XCTAssertTrue(testView.translatesAutoresizingMaskIntoConstraints)
        XCTAssertTrue(superview.constraints.isEmpty)
    }
    
    func testPBMAddFillSuperviewConstraints() {
        
        // Prepare
        
        superview.addSubview(testView)
        
        let initialConstraints = superview.constraints;
        XCTAssertTrue(initialConstraints.isEmpty)
        
        // Change
        
        testView.PBMAddFillSuperviewConstraints()
        
        // Check constraints
        
        let testConstraints = superview.constraints;
        
        XCTAssertEqual(testConstraints.count, 4)
        for constraint in testConstraints {
            XCTAssertEqual(constraint.firstItem as! UIView, testView)
            XCTAssertEqual(constraint.secondItem as! UIView , superview)
            
            XCTAssertEqual(constraint.firstAttribute, constraint.secondAttribute)
            XCTAssertEqual(constraint.relation, .equal)
            XCTAssertEqual(constraint.constant, 0)
            XCTAssertEqual(constraint.multiplier, 1)
        }
        
        // Check changed properties
        
        XCTAssertFalse(testView.translatesAutoresizingMaskIntoConstraints)
    }
    
    func testPBMAddConstraintsFromCGRect() {
        // Prepare
        
        superview.addSubview(testView)
        
        let initialConstraints = superview.constraints;
        XCTAssertTrue(initialConstraints.isEmpty)
        
        // Change
        
        let testRect = CGRect(x: testX, y: testY, width: testWidth, height: testHeight)
        testView.PBMAddConstraintsFromCGRect(testRect)
        
        // Check constraints
        
        let testConstraints = superview.constraints;
        
        XCTAssertEqual(testConstraints.count, 4)
        for constraint in testConstraints {
            // Common cases
            XCTAssertEqual(constraint.firstItem as! UIView, testView)
            XCTAssertEqual(constraint.relation, .equal)
            XCTAssertEqual(constraint.multiplier, 1)
            
            // Different cases
            switch constraint.firstAttribute {
                
            case .width :
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, testRect.width)
                
            case .height:
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, testRect.height)
                
            case .left:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .left)
                XCTAssertEqual(constraint.constant, testRect.origin.x)
                
            case .top:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .top)
                XCTAssertEqual(constraint.constant, testRect.origin.y)
                
            default:
                XCTFail()
            }
        }
        
        // Check changed properties
        
        XCTAssertFalse(testView.translatesAutoresizingMaskIntoConstraints)
    }
    
    func testPBMAddCropAndCenterConstraints() {
        
        // Prepare
        
        superview.addSubview(testView)
        
        let initialConstraints = superview.constraints;
        XCTAssertTrue(initialConstraints.isEmpty)
        
        // Change
        
        testView.PBMAddCropAndCenterConstraints(initialWidth: testWidth, initialHeight: testHeight)
        
        // Check constraints
        
        let testConstraints = superview.constraints;
        
        XCTAssertEqual(testConstraints.count, 6)
        for constraint in testConstraints {
            // Common cases
            XCTAssertEqual(constraint.firstItem as! UIView, testView)
            XCTAssertEqual(constraint.multiplier, 1)
            
            // Different cases
            switch constraint.firstAttribute {
                
            case .centerX:
                XCTAssertEqual(constraint.secondItem as? UIView, superview)
                XCTAssertEqual(constraint.relation, .equal)
                XCTAssertEqual(constraint.secondAttribute, .centerX)
                XCTAssertEqual(constraint.constant, 0)
                
            case .centerY:
                XCTAssertEqual(constraint.secondItem as? UIView, superview)
                XCTAssertEqual(constraint.relation, .equal)
                XCTAssertEqual(constraint.secondAttribute, .centerY)
                XCTAssertEqual(constraint.constant, 0)
                
            case .width:
                if (constraint.relation == .equal) {
                    XCTAssertEqual(constraint.secondItem as? UIView, nil)
                    XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                    XCTAssertEqual(constraint.constant, testWidth)
                    XCTAssertEqual(constraint.priority, UILayoutPriority(rawValue: 750))
                } else if (constraint.relation == .lessThanOrEqual) {
                    XCTAssertEqual(constraint.secondItem as? UIView, superview)
                    XCTAssertEqual(constraint.secondAttribute, .width)
                    XCTAssertEqual(constraint.constant, 0)
                } else {
                    XCTFail()
                }
                
            case .height:
                if (constraint.relation == .equal) {
                    XCTAssertEqual(constraint.secondItem as? UIView, nil)
                    XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                    XCTAssertEqual(constraint.constant, testHeight)
                    XCTAssertEqual(constraint.priority, UILayoutPriority(rawValue: 750))
                } else if (constraint.relation == .lessThanOrEqual) {
                    XCTAssertEqual(constraint.secondItem as? UIView, superview)
                    XCTAssertEqual(constraint.secondAttribute, .height)
                    XCTAssertEqual(constraint.constant, 0)
                } else {
                    XCTFail()
                }
                
            default:
                XCTFail()
            }
        }
        
        // Check changed properties
        
        XCTAssertFalse(testView.translatesAutoresizingMaskIntoConstraints)
    }
    
    func testPBMAddBottomRightConstraints() {
        
        // Prepare
        
        superview.addSubview(testView)
        
        let initialConstraints = superview.constraints;
        XCTAssertTrue(initialConstraints.isEmpty)
        
        // Change
        
        let viewSize = CGSize(width: 120, height: 110)
        let marginSize = CGSize(width: testWidth, height: testHeight)
        testView.PBMAddBottomRightConstraints(viewSize: viewSize, marginSize: marginSize)
        
        // Check constraints
        
        let testConstraints = superview.constraints;
        
        XCTAssertEqual(testConstraints.count, 4)
        for constraint in testConstraints {
            // Common cases
            XCTAssertEqual(constraint.firstItem as! UIView, testView)
            XCTAssertEqual(constraint.relation, .equal)
            XCTAssertEqual(constraint.multiplier, 1)
            
            // Different cases
            switch constraint.firstAttribute {
                
            case .width :
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, viewSize.width)
                
            case .height:
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, viewSize.height)
                
            case .right:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .right)
                XCTAssertEqual(constraint.constant, marginSize.width)
                
            case .bottom:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .bottom)
                XCTAssertEqual(constraint.constant, marginSize.height)
                
            default:
                XCTFail()
            }
        }
        
        // Check changed properties
        
        XCTAssertFalse(testView.translatesAutoresizingMaskIntoConstraints)
    }
    
    func testPBMAddTopRightConstraints() {
        
        // Prepare
        
        superview.addSubview(testView)
        
        let initialConstraints = superview.constraints;
        XCTAssertTrue(initialConstraints.isEmpty)
        
        // Change
        
        let viewSize = CGSize(width: 120, height: 110)
        let marginSize = CGSize(width: testWidth, height: testHeight)
        testView.PBMAddTopRightConstraints(viewSize: viewSize, marginSize: marginSize)
        
        // Check constraints
        
        let testConstraints = superview.constraints;
        
        XCTAssertEqual(testConstraints.count, 4)
        for constraint in testConstraints {
            // Common cases
            XCTAssertEqual(constraint.firstItem as! UIView, testView)
            XCTAssertEqual(constraint.relation, .equal)
            XCTAssertEqual(constraint.multiplier, 1)
            
            // Different cases
            switch constraint.firstAttribute {
                
            case .width :
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, viewSize.width)
                
            case .height:
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, viewSize.height)
                
            case .right:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .right)
                XCTAssertEqual(constraint.constant, marginSize.width)
                
            case .top:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .top)
                XCTAssertEqual(constraint.constant, marginSize.height)
                
            default:
                XCTFail()
            }
        }
        
        // Check changed properties
        
        XCTAssertFalse(testView.translatesAutoresizingMaskIntoConstraints)
    }
    
    func testPBMAddTopLeftConstraints() {
        
        // Prepare
        
        superview.addSubview(testView)
        
        let initialConstraints = superview.constraints;
        XCTAssertTrue(initialConstraints.isEmpty)
        
        // Change
        
        let viewSize = CGSize(width: 120, height: 110)
        let marginSize = CGSize(width: testWidth, height: testHeight)
        testView.PBMAddTopLeftConstraints(viewSize: viewSize, marginSize: marginSize)
        
        // Check constraints
        
        let testConstraints = superview.constraints;
        
        XCTAssertEqual(testConstraints.count, 4)
        for constraint in testConstraints {
            // Common cases
            XCTAssertEqual(constraint.firstItem as! UIView, testView)
            XCTAssertEqual(constraint.relation, .equal)
            XCTAssertEqual(constraint.multiplier, 1)
            
            // Different cases
            switch constraint.firstAttribute {
                
            case .width :
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, viewSize.width)
                
            case .height:
                XCTAssertEqual(constraint.secondItem as? UIView, nil)
                XCTAssertEqual(constraint.secondAttribute, .notAnAttribute)
                XCTAssertEqual(constraint.constant, viewSize.height)
                
            case .right:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .right)
                XCTAssertEqual(constraint.constant, marginSize.width)
                
            case .top:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .top)
                XCTAssertEqual(constraint.constant, marginSize.height)
                
            case .left:
                XCTAssertEqual(constraint.secondItem as! UIView , superview)
                XCTAssertEqual(constraint.secondAttribute, .left)
                XCTAssertEqual(constraint.constant, marginSize.width)
                
            default:
                XCTFail()
            }
        }
        
        // Check changed properties
        
        XCTAssertFalse(testView.translatesAutoresizingMaskIntoConstraints)
    }
    
    // The purpose of this test to check if all subviews were reflected in the log or not.
    func testLogViewHierarchyForView() {
        // Prepare
        
        
        // Count of subviews by levels
        // Can be changed to any
        let testViewLevels = [2, 4, 3]
        let testView = createFakeViewHierarchy(subviewsCount: testViewLevels)
        
        logToFile = .init()
        
        
        // Call test method
        
        testView.logViewHierarchy()
        
        // Check log
        
        let log = Log.getLogFileAsString() ?? ""
        
        XCTAssertTrue(log.contains("LOGGING VIEW HIERARCHY"))
        
        // Check count of occurrences for each subviews level
        for i in 0 ..< testViewLevels.count {
            let occurrences = countViewOccurrencesIn(log, with: i)
            let expected = countViewExpected(for: i, hierarchy: testViewLevels)
            
            XCTAssertEqual(occurrences, expected)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createFakeViewHierarchy(subviewsCount:[Int]) -> UIView {
        let parentView = UIView()
        
        addSubviews(view: parentView, subviewsCount: subviewsCount)
        
        return parentView
    }
    
    private func addSubviews(view: UIView, subviewsCount:[Int]) {
        var subviewsCount = subviewsCount
        if subviewsCount.isEmpty {
            return
        }
        
        for _ in 0 ..< subviewsCount.removeFirst() {
            view.addSubview(UIView())
        }
        
        for subview in view.subviews {
            addSubviews(view: subview, subviewsCount: subviewsCount)
        }
    }
    
    // This methods returns the number of log occurrences for view in particular level
    // the entry of view in log looks like:
    // [Line 130]: --view = <UIView: 0x7fb5d78ccca0; frame = (0 0; 0 0); layer = .....
    // "--" shows the level in the hierarchy
    private func countViewOccurrencesIn(_ log: String, with level:Int) -> Int {
        var levelPrefix = ""
        for _ in 0 ..< level {
            levelPrefix += "-"
        }
        
        let logPrefix = "-> " + levelPrefix + "view = "
        return log.components(separatedBy: logPrefix).count - 1
    }
    
    // This method retuns the count of view's occurences according to given level in the hierarchy
    // For current test just need to multiply count of all parent levels
    private func countViewExpected(for level:Int, hierarchy:[Int]) -> Int {
        var ret = 1
        
        for i in 0 ..< level {
            ret *= hierarchy[i]
        }
        
        return ret
    }
}
