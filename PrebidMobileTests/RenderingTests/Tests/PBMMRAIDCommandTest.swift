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
@_spi(PBMInternal) @testable import PrebidMobile

class PBMMRAIDCommandTest : XCTestCase {
    
    func testInit() {
        
        //Cover the three cases that would result in an error
        var expectedErrorMessage = "URL does not contain MRAID scheme"
        do {
            _ = try MRAIDCommand(url: "mraid_bad_scheme:expand")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.PBMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        expectedErrorMessage = "Command not found"
        do {
            _ = try MRAIDCommand(url: "mraid:")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.PBMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        expectedErrorMessage = "Unrecognized MRAID command"
        do {
            _ = try MRAIDCommand(url: "mraid:bad_command")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.PBMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        
        var pbmMRAIDCommand:MRAIDCommand
        
        do {
            
            //Test all commands
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:open")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.open.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:expand")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.expand.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:resize")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.resize.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:close")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.close.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:playVideo")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.playVideo.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:log")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.log.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:onOrientationPropertiesChanged")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.onOrientationPropertiesChanged.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            //Case sensitivity
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:ONORIENTATIONPROPERTIESCHANGED")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.onOrientationPropertiesChanged.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:eXpAnD")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.expand.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            //mixed
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:OPEN")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.open.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == [])
            
            //Arguments
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:expand/foo.com")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.expand.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == ["foo.com"])
            
            //%-substitution
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:expand/foo.com%20bar")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.expand.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == ["foo.com bar"])
            
            //Lots of arguments
            pbmMRAIDCommand = try MRAIDCommand(url: "mraid:expand/foo/bar/baz")
            XCTAssertEqual(pbmMRAIDCommand.command, PBMMRAIDAction.expand.rawValue)
            XCTAssert(pbmMRAIDCommand.arguments == ["foo", "bar", "baz"])
            
        } catch let error as PBMError {
            XCTFail(error.description)
        } catch {
            XCTFail()
        }
    }
}
