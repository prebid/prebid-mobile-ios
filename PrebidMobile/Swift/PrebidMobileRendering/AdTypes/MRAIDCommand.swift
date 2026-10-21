//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

class MRAIDCommand: NSObject {

    /// One of the `MRAIDAction` constants.
    let command: String
    let arguments: [String]

    // `url` stays optional although the ObjC header said `nonnull`: the ObjC original had a nil guard and
    // PBMMRAIDController.m, a surviving ObjC caller, builds the string (playbook S2.2-B, S3.1-H).
    init(url: String?) throws {

        // Prepare `command`

        guard let url else {
            throw Self.error(description: "URL is nil")
        }

        // NSString searching/splitting/comparison throughout, as the ObjC original used (playbook S6.x-K-A)
        let urlString = url as NSString
        let schemeRange = urlString.range(of: MRAIDConstants.mraidURLScheme)
        let schemeEnd = schemeRange.location + schemeRange.length

        // `-[NSString PBMsubstringFromString:]` raised NSRangeException when the scheme was found anywhere but at the
        // start of a string that continues after it. Swift cannot raise an ObjC exception, so this fails like
        // a missing scheme. The controller turned the exception into a logged warning, as it does with the error.
        let isSchemeUnusable = schemeRange.location == NSNotFound
            || (schemeRange.location > 0 && schemeEnd < urlString.length)
        guard !isSchemeUnusable else {
            throw Self.error(description: "URL does not contain MRAID scheme: \(url)")
        }

        let mraidPath = schemeEnd < urlString.length ? urlString.substring(from: schemeEnd) : ""

        var components = (mraidPath as NSString).components(separatedBy: "/")
        let commandString = ((components.first ?? "") as NSString).lowercased
        guard !commandString.isEmpty else {
            throw Self.error(description: "Command not found in MRAID url: \(url)")
        }

        var parsedCommandString: String?
        for constant in MRAIDConstants.allCases where ((constant as NSString).lowercased as NSString).isEqual(to: commandString) {
            parsedCommandString = constant
            break
        }

        guard let parsedCommandString else {
            throw Self.error(description: "Unrecognized MRAID command \(commandString)")
        }

        // Prepare `arguments`

        components.removeFirst()
        var parsedArguments = [String]()

        for component in components {
            guard let componentWithPercentEncodingResolved = component.removingPercentEncoding else {
                throw Self.error(description: "Unable to parse MRAID command argument: \(component) on url: \(url)")
            }
            parsedArguments.append(componentWithPercentEncodingResolved)
        }

        // Init the object

        command = parsedCommandString
        arguments = parsedArguments
        super.init()
    }

    // Matches `+[PBMError createError:description:]`, which logged the error it created.
    private static func error(description: String) -> PBMError {
        let error = PBMError.error(description: description)
        Log.error("\(error)")
        return error
    }
}
