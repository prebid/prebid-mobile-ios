import Foundation
import XCTest

import UIKit
@testable import PrebidMobileRendering

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

            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:storePicture")
            XCTAssertEqual(pbmMRAIDCommand.command, .storePicture)
            XCTAssert(pbmMRAIDCommand.arguments == [])

            pbmMRAIDCommand = try PBMMRAIDCommand(url: "mraid:createCalendarEvent")
            XCTAssertEqual(pbmMRAIDCommand.command, .createCalendarEvent)
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
