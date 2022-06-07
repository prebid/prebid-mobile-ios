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

import UIKit
@testable import PrebidMobile

class PBMMRAIDCommandTest : XCTestCase {
    
    func testInit() {
        
        //Cover the three cases that would result in an error
        var expectedErrorMessage = "URL does not contain MRAID scheme"
        do {
            _ = try PBMMRAIDCommand(url: "mraid_bad_scheme:expand")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.PBMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        expectedErrorMessage = "Command not found"
        do {
            _ = try PBMMRAIDCommand(url: "mraid:")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.PBMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        expectedErrorMessage = "Unrecognized MRAID command"
        do {
            _ = try PBMMRAIDCommand(url: "mraid:bad_command")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.PBMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        
        var pbmMRAIDCommand:PBMMRAIDCommand
        
        do {
            
            //Test all commands
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:open")
            XCTAssertEqual(pbmMRAIDCommand.command, .open)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:expand")
            XCTAssertEqual(pbmMRAIDCommand.command, .expand)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:resize")
            XCTAssertEqual(pbmMRAIDCommand.command, .resize)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:close")
            XCTAssertEqual(pbmMRAIDCommand.command, .close)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:playVideo")
            XCTAssertEqual(pbmMRAIDCommand.command, .playVideo)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:log")
            XCTAssertEqual(pbmMRAIDCommand.command, .log)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:onOrientationPropertiesChanged")
            XCTAssertEqual(pbmMRAIDCommand.command, .onOrientationPropertiesChanged)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            //Case sensitivity
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:ONORIENTATIONPROPERTIESCHANGED")
            XCTAssertEqual(pbmMRAIDCommand.command, .onOrientationPropertiesChanged)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:eXpAnD")
            XCTAssertEqual(pbmMRAIDCommand.command, .expand)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            //mixed
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:OPEN")
            XCTAssertEqual(pbmMRAIDCommand.command, .open)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            //Arguments
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:expand/foo.com")
            XCTAssertEqual(pbmMRAIDCommand.command, .expand)
            XCTAssert(pbmMRAIDCommand.arguments == ["foo.com"])
            
            //%-substitution
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:expand/foo.com%20bar")
            XCTAssertEqual(pbmMRAIDCommand.command, .expand)
            XCTAssert(pbmMRAIDCommand.arguments == ["foo.com bar"])
            
            //Lots of arguments
            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:expand/foo/bar/baz")
            XCTAssertEqual(pbmMRAIDCommand.command, .expand)
            XCTAssert(pbmMRAIDCommand.arguments == ["foo", "bar", "baz"])
            
        } catch let error as PBMError {
            XCTFail(error.description)
        } catch {
            XCTFail()
        }
    }
}
