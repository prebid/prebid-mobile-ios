import Foundation
import XCTest

import UIKit
@testable import PrebidMobileRendering

class OXMMRAIDCommandTest : XCTestCase {
    
    func testInit() {

        //Cover the three cases that would result in an error
        var expectedErrorMessage = "URL does not contain MRAID scheme"
        do {
            _ = try OXMMRAIDCommand(url: "mraid_bad_scheme:expand")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.OXMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }
        
        expectedErrorMessage = "Command not found"
        do {
            _ = try OXMMRAIDCommand(url: "mraid:")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.OXMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }

        expectedErrorMessage = "Unrecognized MRAID command"
        do {
            _ = try OXMMRAIDCommand(url: "mraid:bad_command")
            XCTFail("Should have caught \(expectedErrorMessage) error")
        } catch let error as NSError {
            XCTAssert(error.localizedDescription.OXMdoesMatch(expectedErrorMessage), "Expected \(expectedErrorMessage), got \(error.localizedDescription)")
        } catch {
            XCTFail("Should have caught \(expectedErrorMessage)")
        }

        
        var oxmMRAIDCommand:OXMMRAIDCommand

        do {
        
            //Test all commands
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:open")
            XCTAssertEqual(oxmMRAIDCommand.command, .open)
            XCTAssert(oxmMRAIDCommand.arguments == [])
            
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:expand")
            XCTAssertEqual(oxmMRAIDCommand.command, .expand)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:resize")
            XCTAssertEqual(oxmMRAIDCommand.command, .resize)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:close")
            XCTAssertEqual(oxmMRAIDCommand.command, .close)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:storePicture")
            XCTAssertEqual(oxmMRAIDCommand.command, .storePicture)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:createCalendarEvent")
            XCTAssertEqual(oxmMRAIDCommand.command, .createCalendarEvent)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:playVideo")
            XCTAssertEqual(oxmMRAIDCommand.command, .playVideo)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:log")
            XCTAssertEqual(oxmMRAIDCommand.command, .log)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:onOrientationPropertiesChanged")
            XCTAssertEqual(oxmMRAIDCommand.command, .onOrientationPropertiesChanged)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            //Case sensitivity
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:ONORIENTATIONPROPERTIESCHANGED")
            XCTAssertEqual(oxmMRAIDCommand.command, .onOrientationPropertiesChanged)
            XCTAssert(oxmMRAIDCommand.arguments == [])
            
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:eXpAnD")
            XCTAssertEqual(oxmMRAIDCommand.command, .expand)
            XCTAssert(oxmMRAIDCommand.arguments == [])

            //mixed
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:OPEN")
            XCTAssertEqual(oxmMRAIDCommand.command, .open)
            XCTAssert(oxmMRAIDCommand.arguments == [])
            
            //Arguments
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:expand/foo.com")
            XCTAssertEqual(oxmMRAIDCommand.command, .expand)
            XCTAssert(oxmMRAIDCommand.arguments == ["foo.com"])

            //%-substitution
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:expand/foo.com%20bar")
            XCTAssertEqual(oxmMRAIDCommand.command, .expand)
            XCTAssert(oxmMRAIDCommand.arguments == ["foo.com bar"])

            //Lots of arguments
            oxmMRAIDCommand = try OXMMRAIDCommand(url: "mraid:expand/foo/bar/baz")
            XCTAssertEqual(oxmMRAIDCommand.command, .expand)
            XCTAssert(oxmMRAIDCommand.arguments == ["foo", "bar", "baz"])
            
        } catch let error as OXMError {
            XCTFail(error.description)
        } catch {
            XCTFail()
        }

    }
}
