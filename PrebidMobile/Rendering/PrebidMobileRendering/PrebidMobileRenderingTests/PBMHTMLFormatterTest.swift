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

class PBMHTMLFormatterTest: XCTestCase {
    
    let htmlOpeningTag = "<html>"
    let htmlClosingTag = "</html>"
    let bodyOpeningTag = "<body>"
    let bodyClosingTag = "</body>"

    func testhtmlWithBodyAndHTMLTags() {
        
        /*
         <html><body style='margin: 0; padding: 0;'><div id="oxm_content"><div id="ad">
         <a href="http://openx.com/product/ad-server/">
         <img src="http://i-cdn.openx.com/5a7/5a731840-5ae7-4dca-ba66-6e959bb763e2/93e/93e8623e977d43df87d8c6087142e838.png" alt="Banner Advertisement" height="50" width="320"></a>
         </div></div></body></html>
         */
        
        let baseCreative = "<div id=\"ad\">\n<a href=\"http://openx.com/product/ad-server/\">\n<img src=\"http://i-cdn.openx.com/5a7/5a731840-5ae7-4dca-ba66-6e959bb763e2/93e/93e8623e977d43df87d8c6087142e838.png\" alt=\"Banner Advertisement\" height=\"50\" width=\"320\"></a>\n</div>"
        
        let htmlMissingHTMLTags = "\(bodyOpeningTag)\(baseCreative)\(bodyClosingTag)"
        let properlyFormedHTML = "\(htmlOpeningTag)\(htmlMissingHTMLTags)\(htmlClosingTag)"
        
        let htmlMissingHTMLClosingTag = "\(htmlMissingHTMLTags)\(htmlClosingTag)"
        let htmlMissingHTMLOpeningTag = "\(htmlOpeningTag)\(htmlMissingHTMLTags)"
        
        let expected = properlyFormedHTML
        var actual:String
        
        actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(htmlMissingHTMLTags)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add html tags = \(expected), actual = \(actual)")
        
        actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(baseCreative)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add html and body tags. Expected = \(expected), actual = \(actual)")
        
        actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(properlyFormedHTML)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to not modify properlyFormedHTML. Expected = \(expected), actual = \(actual)")
        
        actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(htmlMissingHTMLOpeningTag)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add missing tag. Expected = \(expected), actual = \(actual)")
        
        actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(htmlMissingHTMLClosingTag)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add missing tag. Expected = \(expected), actual = \(actual)")
    }
    
    func testJSScriptFormatting() {
        
        /**
         <html> <head> <script src="mraid.js"></script> <script> function someFunc() { // some code } </script> </head> <body><div id="aroniabtestad"></div></body> </html>
         */
        
        var htmlWithScript = "\(htmlOpeningTag) <head> <script src=\"mraid.js\"></script> <script> function someFunc() { // some code } </script> </head> \(bodyOpeningTag)<div id=\"aroniabtestad\"></div>\(bodyClosingTag) \(htmlClosingTag)"
        var expected = htmlWithScript
        var actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(htmlWithScript)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add missing tag. Expected = \(expected), actual = \(actual)")

        
        /**
         <script src="mraid.js"></script> <script> function someFunc() { // some code } </script> <div id="arontwopartwrap"> <a href="#" onclick="twopart(); return false;" id="twopart">blah blah</a> </div>
         */
        
        htmlWithScript = "<script src=\"mraid.js\"></script> <script> function someFunc() { // some code } </script> <div id=\"arontwopartwrap\"> <a href=\"#\" onclick=\"twopart(); return false;\" id=\"twopart\">blah blah</a> </div>"
        expected = "\(htmlOpeningTag)\(bodyOpeningTag)\(htmlWithScript)\(bodyClosingTag)\(htmlClosingTag)"
        actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(htmlWithScript)
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add missing tag. Expected = \(expected), actual = \(actual)")
    }
    
    func testWithWrongStyleTagFormatting() {
        
        let htmlStyleOpeningTag = "<html style="
        let redColorText = "\"color:red”>blah blah"
        
        // <html style=“color:red”>blah blah</html>
        let htmlStileOpeningTag = "\(htmlStyleOpeningTag)\(redColorText)\(htmlClosingTag)"
        
        let actual = PBMHTMLFormatter.ensureHTMLHasBodyAndHTMLTags(htmlStileOpeningTag)
        let expected = "\(htmlOpeningTag)\(bodyOpeningTag)\(htmlStyleOpeningTag)\(redColorText)\(bodyClosingTag)\(htmlClosingTag)"
        XCTAssert(expected == actual, "Expected ensureHTMLHasBodyAndHTMLTags to add missing tag. Expected = \(expected), actual = \(actual)")
    }
}
