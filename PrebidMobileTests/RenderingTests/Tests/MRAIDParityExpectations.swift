/*   Copyright 2018-2025 Prebid.org, Inc.

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

// swiftlint:disable line_length

import Foundation

/// Expected output of `MRAIDParityDump.dump()`, one `key => value` line per input.
///
/// These values were captured from the Objective-C `PBMMRAIDJavascriptCommands`, `PBMMRAIDCommand` and `PBMHTMLFormatter`
/// before they were ported to Swift (Phase 7, agent 1B), so they pin the Swift classes to the behavior of the originals,
/// not to themselves. Do not regenerate them from the Swift port. A change here means observable behavior changed.
///
/// Left out on purpose: the inputs on which the Objective-C code raised an exception (an MRAID scheme found after the
/// start of the URL, and a nil HTML string), because Swift cannot reproduce an Objective-C exception. See
/// `MRAIDParityTests.testSchemeAfterStartOfURLIsRejected`.
enum MRAIDParityExpectations {

    static let expected = #"""
js.isEnabled => "typeof mraid !== 'undefined'"
js.nativeCallComplete => "mraid.nativeCallComplete();"
js.onReady => "mraid.onReady();"
js.onReadyExpanded => "mraid.onReadyExpanded();"
js.getCurrentPosition => "JSON.stringify(mraid.getCurrentPosition());"
js.getOrientationProperties => "JSON.stringify(mraid.getOrientationProperties());"
js.getExpandProperties => "JSON.stringify(mraid.getExpandProperties());"
js.getResizeProperties => "JSON.stringify(mraid.getResizeProperties());"
js.updateSupportedFeatures => "mraid.allSupports = {\"location\":true,\"vpaid\":false,\"inlineVideo\":true,\"storePicture\":false,\"calendar\":false,\"sms\":true,\"tel\":true};"
js.onViewableChange.true => "mraid.onViewableChange(true);"
js.onViewableChange.false => "mraid.onViewableChange(false);"
js.onSizeChange.00 => "mraid.onSizeChange(0.0,-1.1);"
js.updateMaxSize.00 => "mraid.setMaxSize(0.0,-1.1);"
js.updateScreenSize.00 => "mraid.screenSize = {width:0.0,height:-1.1};"
js.updateDefaultPosition.00 => "mraid.defaultPosition = {x:0.0, y:-0.0, width:1.0, height:-1.1};"
js.updateCurrentPosition.00 => "mraid.currentPosition = {x:0.0, y:-0.0, width:1.0, height:-1.1};"
js.updateLocation.00 => "mraid.setLocation(0.0,-0.0,1.0,-1.1);"
js.onSizeChange.01 => "mraid.onSizeChange(-0.0,1.1111);"
js.updateMaxSize.01 => "mraid.setMaxSize(-0.0,1.1111);"
js.updateScreenSize.01 => "mraid.screenSize = {width:-0.0,height:1.1111};"
js.updateDefaultPosition.01 => "mraid.defaultPosition = {x:-0.0, y:1.0, width:-1.1, height:1.1111};"
js.updateCurrentPosition.01 => "mraid.currentPosition = {x:-0.0, y:1.0, width:-1.1, height:1.1111};"
js.updateLocation.01 => "mraid.setLocation(-0.0,1.0,-1.1,1.1111);"
js.onSizeChange.02 => "mraid.onSizeChange(1.0,0.0);"
js.updateMaxSize.02 => "mraid.setMaxSize(1.0,0.0);"
js.updateScreenSize.02 => "mraid.screenSize = {width:1.0,height:0.0};"
js.updateDefaultPosition.02 => "mraid.defaultPosition = {x:1.0, y:-1.1, width:1.1111, height:0.0};"
js.updateCurrentPosition.02 => "mraid.currentPosition = {x:1.0, y:-1.1, width:1.1111, height:0.0};"
js.updateLocation.02 => "mraid.setLocation(1.0,-1.1,1.1111,0.0);"
js.onSizeChange.03 => "mraid.onSizeChange(-1.1,0.0002);"
js.updateMaxSize.03 => "mraid.setMaxSize(-1.1,0.0002);"
js.updateScreenSize.03 => "mraid.screenSize = {width:-1.1,height:0.0002};"
js.updateDefaultPosition.03 => "mraid.defaultPosition = {x:-1.1, y:1.1111, width:0.0, height:0.0002};"
js.updateCurrentPosition.03 => "mraid.currentPosition = {x:-1.1, y:1.1111, width:0.0, height:0.0002};"
js.updateLocation.03 => "mraid.setLocation(-1.1,1.1111,0.0,0.0002);"
js.onSizeChange.04 => "mraid.onSizeChange(1.1111,0.0002);"
js.updateMaxSize.04 => "mraid.setMaxSize(1.1111,0.0002);"
js.updateScreenSize.04 => "mraid.screenSize = {width:1.1111,height:0.0002};"
js.updateDefaultPosition.04 => "mraid.defaultPosition = {x:1.1111, y:0.0, width:0.0002, height:0.0002};"
js.updateCurrentPosition.04 => "mraid.currentPosition = {x:1.1111, y:0.0, width:0.0002, height:0.0002};"
js.updateLocation.04 => "mraid.setLocation(1.1111,0.0,0.0002,0.0002);"
js.onSizeChange.05 => "mraid.onSizeChange(0.0,0.0004);"
js.updateMaxSize.05 => "mraid.setMaxSize(0.0,0.0004);"
js.updateScreenSize.05 => "mraid.screenSize = {width:0.0,height:0.0004};"
js.updateDefaultPosition.05 => "mraid.defaultPosition = {x:0.0, y:0.0002, width:0.0002, height:0.0004};"
js.updateCurrentPosition.05 => "mraid.currentPosition = {x:0.0, y:0.0002, width:0.0002, height:0.0004};"
js.updateLocation.05 => "mraid.setLocation(0.0,0.0002,0.0002,0.0004);"
js.onSizeChange.06 => "mraid.onSizeChange(0.0002,0.1234);"
js.updateMaxSize.06 => "mraid.setMaxSize(0.0002,0.1234);"
js.updateScreenSize.06 => "mraid.screenSize = {width:0.0002,height:0.1234};"
js.updateDefaultPosition.06 => "mraid.defaultPosition = {x:0.0002, y:0.0002, width:0.0004, height:0.1234};"
js.updateCurrentPosition.06 => "mraid.currentPosition = {x:0.0002, y:0.0002, width:0.0004, height:0.1234};"
js.updateLocation.06 => "mraid.setLocation(0.0002,0.0002,0.0004,0.1234);"
js.onSizeChange.07 => "mraid.onSizeChange(0.0002,1.0);"
js.updateMaxSize.07 => "mraid.setMaxSize(0.0002,1.0);"
js.updateScreenSize.07 => "mraid.screenSize = {width:0.0002,height:1.0};"
js.updateDefaultPosition.07 => "mraid.defaultPosition = {x:0.0002, y:0.0004, width:0.1234, height:1.0};"
js.updateCurrentPosition.07 => "mraid.currentPosition = {x:0.0002, y:0.0004, width:0.1234, height:1.0};"
js.updateLocation.07 => "mraid.setLocation(0.0002,0.0004,0.1234,1.0);"
js.onSizeChange.08 => "mraid.onSizeChange(0.0004,0.0);"
js.updateMaxSize.08 => "mraid.setMaxSize(0.0004,0.0);"
js.updateScreenSize.08 => "mraid.screenSize = {width:0.0004,height:0.0};"
js.updateDefaultPosition.08 => "mraid.defaultPosition = {x:0.0004, y:0.1234, width:1.0, height:0.0};"
js.updateCurrentPosition.08 => "mraid.currentPosition = {x:0.0004, y:0.1234, width:1.0, height:0.0};"
js.updateLocation.08 => "mraid.setLocation(0.0004,0.1234,1.0,0.0);"
js.onSizeChange.09 => "mraid.onSizeChange(0.1234,-0.0);"
js.updateMaxSize.09 => "mraid.setMaxSize(0.1234,-0.0);"
js.updateScreenSize.09 => "mraid.screenSize = {width:0.1234,height:-0.0};"
js.updateDefaultPosition.09 => "mraid.defaultPosition = {x:0.1234, y:1.0, width:0.0, height:-0.0};"
js.updateCurrentPosition.09 => "mraid.currentPosition = {x:0.1234, y:1.0, width:0.0, height:-0.0};"
js.updateLocation.09 => "mraid.setLocation(0.1234,1.0,0.0,-0.0);"
js.onSizeChange.10 => "mraid.onSizeChange(1.0,1234567.891);"
js.updateMaxSize.10 => "mraid.setMaxSize(1.0,1234567.891);"
js.updateScreenSize.10 => "mraid.screenSize = {width:1.0,height:1234567.891};"
js.updateDefaultPosition.10 => "mraid.defaultPosition = {x:1.0, y:0.0, width:-0.0, height:1234567.891};"
js.updateCurrentPosition.10 => "mraid.currentPosition = {x:1.0, y:0.0, width:-0.0, height:1234567.891};"
js.updateLocation.10 => "mraid.setLocation(1.0,0.0,-0.0,1234567.891);"
js.onSizeChange.11 => "mraid.onSizeChange(0.0,375.0);"
js.updateMaxSize.11 => "mraid.setMaxSize(0.0,375.0);"
js.updateScreenSize.11 => "mraid.screenSize = {width:0.0,height:375.0};"
js.updateDefaultPosition.11 => "mraid.defaultPosition = {x:0.0, y:-0.0, width:1234567.891, height:375.0};"
js.updateCurrentPosition.11 => "mraid.currentPosition = {x:0.0, y:-0.0, width:1234567.891, height:375.0};"
js.updateLocation.11 => "mraid.setLocation(0.0,-0.0,1234567.891,375.0);"
js.onSizeChange.12 => "mraid.onSizeChange(-0.0,1024.5);"
js.updateMaxSize.12 => "mraid.setMaxSize(-0.0,1024.5);"
js.updateScreenSize.12 => "mraid.screenSize = {width:-0.0,height:1024.5};"
js.updateDefaultPosition.12 => "mraid.defaultPosition = {x:-0.0, y:1234567.891, width:375.0, height:1024.5};"
js.updateCurrentPosition.12 => "mraid.currentPosition = {x:-0.0, y:1234567.891, width:375.0, height:1024.5};"
js.updateLocation.12 => "mraid.setLocation(-0.0,1234567.891,375.0,1024.5);"
js.onSizeChange.13 => "mraid.onSizeChange(1234567.891,NaN);"
js.updateMaxSize.13 => "mraid.setMaxSize(1234567.891,NaN);"
js.updateScreenSize.13 => "mraid.screenSize = {width:1234567.891,height:NaN};"
js.updateDefaultPosition.13 => "mraid.defaultPosition = {x:1234567.891, y:375.0, width:1024.5, height:NaN};"
js.updateCurrentPosition.13 => "mraid.currentPosition = {x:1234567.891, y:375.0, width:1024.5, height:NaN};"
js.updateLocation.13 => "mraid.setLocation(1234567.891,375.0,1024.5,NaN);"
js.onSizeChange.14 => "mraid.onSizeChange(375.0,+\u{221E});"
js.updateMaxSize.14 => "mraid.setMaxSize(375.0,+\u{221E});"
js.updateScreenSize.14 => "mraid.screenSize = {width:375.0,height:+\u{221E}};"
js.updateDefaultPosition.14 => "mraid.defaultPosition = {x:375.0, y:1024.5, width:NaN, height:+\u{221E}};"
js.updateCurrentPosition.14 => "mraid.currentPosition = {x:375.0, y:1024.5, width:NaN, height:+\u{221E}};"
js.updateLocation.14 => "mraid.setLocation(375.0,1024.5,NaN,+\u{221E});"
js.onSizeChange.15 => "mraid.onSizeChange(1024.5,-\u{221E});"
js.updateMaxSize.15 => "mraid.setMaxSize(1024.5,-\u{221E});"
js.updateScreenSize.15 => "mraid.screenSize = {width:1024.5,height:-\u{221E}};"
js.updateDefaultPosition.15 => "mraid.defaultPosition = {x:1024.5, y:NaN, width:+\u{221E}, height:-\u{221E}};"
js.updateCurrentPosition.15 => "mraid.currentPosition = {x:1024.5, y:NaN, width:+\u{221E}, height:-\u{221E}};"
js.updateLocation.15 => "mraid.setLocation(1024.5,NaN,+\u{221E},-\u{221E});"
js.onSizeChange.16 => "mraid.onSizeChange(NaN,0.0);"
js.updateMaxSize.16 => "mraid.setMaxSize(NaN,0.0);"
js.updateScreenSize.16 => "mraid.screenSize = {width:NaN,height:0.0};"
js.updateDefaultPosition.16 => "mraid.defaultPosition = {x:NaN, y:+\u{221E}, width:-\u{221E}, height:0.0};"
js.updateCurrentPosition.16 => "mraid.currentPosition = {x:NaN, y:+\u{221E}, width:-\u{221E}, height:0.0};"
js.updateLocation.16 => "mraid.setLocation(NaN,+\u{221E},-\u{221E},0.0);"
js.onSizeChange.17 => "mraid.onSizeChange(+\u{221E},12345678901234567000.0);"
js.updateMaxSize.17 => "mraid.setMaxSize(+\u{221E},12345678901234567000.0);"
js.updateScreenSize.17 => "mraid.screenSize = {width:+\u{221E},height:12345678901234567000.0};"
js.updateDefaultPosition.17 => "mraid.defaultPosition = {x:+\u{221E}, y:-\u{221E}, width:0.0, height:12345678901234567000.0};"
js.updateCurrentPosition.17 => "mraid.currentPosition = {x:+\u{221E}, y:-\u{221E}, width:0.0, height:12345678901234567000.0};"
js.updateLocation.17 => "mraid.setLocation(+\u{221E},-\u{221E},0.0,12345678901234567000.0);"
js.onSizeChange.18 => "mraid.onSizeChange(-\u{221E},0.5);"
js.updateMaxSize.18 => "mraid.setMaxSize(-\u{221E},0.5);"
js.updateScreenSize.18 => "mraid.screenSize = {width:-\u{221E},height:0.5};"
js.updateDefaultPosition.18 => "mraid.defaultPosition = {x:-\u{221E}, y:0.0, width:12345678901234567000.0, height:0.5};"
js.updateCurrentPosition.18 => "mraid.currentPosition = {x:-\u{221E}, y:0.0, width:12345678901234567000.0, height:0.5};"
js.updateLocation.18 => "mraid.setLocation(-\u{221E},0.0,12345678901234567000.0,0.5);"
js.onSizeChange.19 => "mraid.onSizeChange(0.0,2.5);"
js.updateMaxSize.19 => "mraid.setMaxSize(0.0,2.5);"
js.updateScreenSize.19 => "mraid.screenSize = {width:0.0,height:2.5};"
js.updateDefaultPosition.19 => "mraid.defaultPosition = {x:0.0, y:12345678901234567000.0, width:0.5, height:2.5};"
js.updateCurrentPosition.19 => "mraid.currentPosition = {x:0.0, y:12345678901234567000.0, width:0.5, height:2.5};"
js.updateLocation.19 => "mraid.setLocation(0.0,12345678901234567000.0,0.5,2.5);"
js.onSizeChange.20 => "mraid.onSizeChange(12345678901234567000.0,3.5);"
js.updateMaxSize.20 => "mraid.setMaxSize(12345678901234567000.0,3.5);"
js.updateScreenSize.20 => "mraid.screenSize = {width:12345678901234567000.0,height:3.5};"
js.updateDefaultPosition.20 => "mraid.defaultPosition = {x:12345678901234567000.0, y:0.5, width:2.5, height:3.5};"
js.updateCurrentPosition.20 => "mraid.currentPosition = {x:12345678901234567000.0, y:0.5, width:2.5, height:3.5};"
js.updateLocation.20 => "mraid.setLocation(12345678901234567000.0,0.5,2.5,3.5);"
js.onSizeChange.21 => "mraid.onSizeChange(0.5,-0.0);"
js.updateMaxSize.21 => "mraid.setMaxSize(0.5,-0.0);"
js.updateScreenSize.21 => "mraid.screenSize = {width:0.5,height:-0.0};"
js.updateDefaultPosition.21 => "mraid.defaultPosition = {x:0.5, y:2.5, width:3.5, height:-0.0};"
js.updateCurrentPosition.21 => "mraid.currentPosition = {x:0.5, y:2.5, width:3.5, height:-0.0};"
js.updateLocation.21 => "mraid.setLocation(0.5,2.5,3.5,-0.0);"
js.onSizeChange.22 => "mraid.onSizeChange(2.5,0.0);"
js.updateMaxSize.22 => "mraid.setMaxSize(2.5,0.0);"
js.updateScreenSize.22 => "mraid.screenSize = {width:2.5,height:0.0};"
js.updateDefaultPosition.22 => "mraid.defaultPosition = {x:2.5, y:3.5, width:-0.0, height:0.0};"
js.updateCurrentPosition.22 => "mraid.currentPosition = {x:2.5, y:3.5, width:-0.0, height:0.0};"
js.updateLocation.22 => "mraid.setLocation(2.5,3.5,-0.0,0.0);"
js.onSizeChange.23 => "mraid.onSizeChange(3.5,-0.0);"
js.updateMaxSize.23 => "mraid.setMaxSize(3.5,-0.0);"
js.updateScreenSize.23 => "mraid.screenSize = {width:3.5,height:-0.0};"
js.updateDefaultPosition.23 => "mraid.defaultPosition = {x:3.5, y:-0.0, width:0.0, height:-0.0};"
js.updateCurrentPosition.23 => "mraid.currentPosition = {x:3.5, y:-0.0, width:0.0, height:-0.0};"
js.updateLocation.23 => "mraid.setLocation(3.5,-0.0,0.0,-0.0);"
js.onSizeChange.24 => "mraid.onSizeChange(-0.0,1.0);"
js.updateMaxSize.24 => "mraid.setMaxSize(-0.0,1.0);"
js.updateScreenSize.24 => "mraid.screenSize = {width:-0.0,height:1.0};"
js.updateDefaultPosition.24 => "mraid.defaultPosition = {x:-0.0, y:0.0, width:-0.0, height:1.0};"
js.updateCurrentPosition.24 => "mraid.currentPosition = {x:-0.0, y:0.0, width:-0.0, height:1.0};"
js.updateLocation.24 => "mraid.setLocation(-0.0,0.0,-0.0,1.0);"
js.onExposureChange.0 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 0.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 0.0, \\\"height\\\": 0.0}, \\\"occlusionRectangles\\\": null}\");"
js.onExposureChange.1 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 100.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 100.0, \\\"height\\\": 100.0}, \\\"occlusionRectangles\\\": null}\");"
js.onExposureChange.2 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 50.0, \\\"visibleRectangle\\\": {\\\"x\\\": 1.2346, \\\"y\\\": 2.5, \\\"width\\\": 3.0001, \\\"height\\\": 4.0}, \\\"occlusionRectangles\\\": []}\");"
js.onExposureChange.3 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 33.3, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 100.0, \\\"height\\\": 100.0}, \\\"occlusionRectangles\\\": [{\\\"x\\\": 70.0, \\\"y\\\": 80.0, \\\"width\\\": 30.0, \\\"height\\\": 20.0}, {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 10.0, \\\"height\\\": 10.0}]}\");"
js.onExposureChange.4 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 150.0, \\\"visibleRectangle\\\": {\\\"x\\\": -5.0, \\\"y\\\": -6.0, \\\"width\\\": 7.0, \\\"height\\\": 8.0}, \\\"occlusionRectangles\\\": null}\");"
js.onExposureChange.5 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": -100.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 10000000000.0, \\\"height\\\": 0.0002}, \\\"occlusionRectangles\\\": [{\\\"x\\\": 1.0, \\\"y\\\": 1.0, \\\"width\\\": 1.0, \\\"height\\\": 1.0}]}\");"
js.onExposureChange.6 => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": NaN, \\\"visibleRectangle\\\": {\\\"x\\\": NaN, \\\"y\\\": +\u{221E}, \\\"width\\\": 0.0, \\\"height\\\": 0.0}, \\\"occlusionRectangles\\\": null}\");"
js.onExposureChange.zero => "mraid.onExposureChange(\"{\\\"exposedPercentage\\\": 0.0, \\\"visibleRectangle\\\": {\\\"x\\\": 0.0, \\\"y\\\": 0.0, \\\"width\\\": 0.0, \\\"height\\\": 0.0}, \\\"occlusionRectangles\\\": null}\");"
js.onExposureChange.nil => "mraid.onExposureChange(\"(null)\");"
js.onStateChange.0 => "mraid.onStateChange('not_enabled');"
js.onStateChange.1 => "mraid.onStateChange('default');"
js.onStateChange.2 => "mraid.onStateChange('expanded');"
js.onStateChange.3 => "mraid.onStateChange('hidden');"
js.onStateChange.4 => "mraid.onStateChange('loading');"
js.onStateChange.5 => "mraid.onStateChange('resized');"
js.onStateChange.nil => "mraid.onStateChange('(null)');"
js.onAudioVolumeChange.nil => "mraid.onAudioVolumeChange(null);"
js.onAudioVolumeChange.00 => "mraid.onAudioVolumeChange(0.0);"
js.onAudioVolumeChange.01 => "mraid.onAudioVolumeChange(50.5);"
js.onAudioVolumeChange.02 => "mraid.onAudioVolumeChange(100.0);"
js.onAudioVolumeChange.03 => "mraid.onAudioVolumeChange(-1.0);"
js.onAudioVolumeChange.04 => "mraid.onAudioVolumeChange(NaN);"
js.onAudioVolumeChange.05 => "mraid.onAudioVolumeChange(10000000000.0);"
js.onAudioVolumeChange.06 => "mraid.onAudioVolumeChange(33.3333);"
js.onAudioVolumeChange.07 => "mraid.onAudioVolumeChange(0.1);"
js.onAudioVolumeChange.08 => "mraid.onAudioVolumeChange(7.0);"
js.onAudioVolumeChange.09 => "mraid.onAudioVolumeChange(1.0);"
js.onAudioVolumeChange.10 => "mraid.onAudioVolumeChange(0.0);"
js.onAudioVolumeChange.11 => "mraid.onAudioVolumeChange(+\u{221E});"
js.onAudioVolumeChange.12 => "mraid.onAudioVolumeChange(+\u{221E});"
js.updatePlacementType.0 => "mraid.placementType = 'inline';"
js.updateCurrentAppOrientation.locked.0 => "mraid.setCurrentAppOrientation('inline', true);"
js.updateCurrentAppOrientation.unlocked.0 => "mraid.setCurrentAppOrientation('inline', false);"
js.onError.0.0 => "mraid.onError('inline','inline');"
js.onError.0.1 => "mraid.onError('inline','interstitial');"
js.onError.0.2 => "mraid.onError('inline','');"
js.onError.0.3 => "mraid.onError('inline','a'b');"
js.onError.0.4 => "mraid.onError('inline','it's \"q\"');"
js.onError.0.5 => "mraid.onError('inline','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.0.6 => "mraid.onError('inline','(null)');"
js.updatePlacementType.1 => "mraid.placementType = 'interstitial';"
js.updateCurrentAppOrientation.locked.1 => "mraid.setCurrentAppOrientation('interstitial', true);"
js.updateCurrentAppOrientation.unlocked.1 => "mraid.setCurrentAppOrientation('interstitial', false);"
js.onError.1.0 => "mraid.onError('interstitial','inline');"
js.onError.1.1 => "mraid.onError('interstitial','interstitial');"
js.onError.1.2 => "mraid.onError('interstitial','');"
js.onError.1.3 => "mraid.onError('interstitial','a'b');"
js.onError.1.4 => "mraid.onError('interstitial','it's \"q\"');"
js.onError.1.5 => "mraid.onError('interstitial','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.1.6 => "mraid.onError('interstitial','(null)');"
js.updatePlacementType.2 => "mraid.placementType = '';"
js.updateCurrentAppOrientation.locked.2 => "mraid.setCurrentAppOrientation('', true);"
js.updateCurrentAppOrientation.unlocked.2 => "mraid.setCurrentAppOrientation('', false);"
js.onError.2.0 => "mraid.onError('','inline');"
js.onError.2.1 => "mraid.onError('','interstitial');"
js.onError.2.2 => "mraid.onError('','');"
js.onError.2.3 => "mraid.onError('','a'b');"
js.onError.2.4 => "mraid.onError('','it's \"q\"');"
js.onError.2.5 => "mraid.onError('','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.2.6 => "mraid.onError('','(null)');"
js.updatePlacementType.3 => "mraid.placementType = 'a'b';"
js.updateCurrentAppOrientation.locked.3 => "mraid.setCurrentAppOrientation('a'b', true);"
js.updateCurrentAppOrientation.unlocked.3 => "mraid.setCurrentAppOrientation('a'b', false);"
js.onError.3.0 => "mraid.onError('a'b','inline');"
js.onError.3.1 => "mraid.onError('a'b','interstitial');"
js.onError.3.2 => "mraid.onError('a'b','');"
js.onError.3.3 => "mraid.onError('a'b','a'b');"
js.onError.3.4 => "mraid.onError('a'b','it's \"q\"');"
js.onError.3.5 => "mraid.onError('a'b','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.3.6 => "mraid.onError('a'b','(null)');"
js.updatePlacementType.4 => "mraid.placementType = 'it's \"q\"';"
js.updateCurrentAppOrientation.locked.4 => "mraid.setCurrentAppOrientation('it's \"q\"', true);"
js.updateCurrentAppOrientation.unlocked.4 => "mraid.setCurrentAppOrientation('it's \"q\"', false);"
js.onError.4.0 => "mraid.onError('it's \"q\"','inline');"
js.onError.4.1 => "mraid.onError('it's \"q\"','interstitial');"
js.onError.4.2 => "mraid.onError('it's \"q\"','');"
js.onError.4.3 => "mraid.onError('it's \"q\"','a'b');"
js.onError.4.4 => "mraid.onError('it's \"q\"','it's \"q\"');"
js.onError.4.5 => "mraid.onError('it's \"q\"','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.4.6 => "mraid.onError('it's \"q\"','(null)');"
js.updatePlacementType.5 => "mraid.placementType = 'unicode \u{00E9} \u{D83D}\u{DE00}';"
js.updateCurrentAppOrientation.locked.5 => "mraid.setCurrentAppOrientation('unicode \u{00E9} \u{D83D}\u{DE00}', true);"
js.updateCurrentAppOrientation.unlocked.5 => "mraid.setCurrentAppOrientation('unicode \u{00E9} \u{D83D}\u{DE00}', false);"
js.onError.5.0 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','inline');"
js.onError.5.1 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','interstitial');"
js.onError.5.2 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','');"
js.onError.5.3 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','a'b');"
js.onError.5.4 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','it's \"q\"');"
js.onError.5.5 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.5.6 => "mraid.onError('unicode \u{00E9} \u{D83D}\u{DE00}','(null)');"
js.updatePlacementType.6 => "mraid.placementType = '(null)';"
js.updateCurrentAppOrientation.locked.6 => "mraid.setCurrentAppOrientation('(null)', true);"
js.updateCurrentAppOrientation.unlocked.6 => "mraid.setCurrentAppOrientation('(null)', false);"
js.onError.6.0 => "mraid.onError('(null)','inline');"
js.onError.6.1 => "mraid.onError('(null)','interstitial');"
js.onError.6.2 => "mraid.onError('(null)','');"
js.onError.6.3 => "mraid.onError('(null)','a'b');"
js.onError.6.4 => "mraid.onError('(null)','it's \"q\"');"
js.onError.6.5 => "mraid.onError('(null)','unicode \u{00E9} \u{D83D}\u{DE00}');"
js.onError.6.6 => "mraid.onError('(null)','(null)');"
cmd.00."mraid:open" => command="open" arguments=[] error=nil
cmd.01."mraid:OPEN" => command="open" arguments=[] error=nil
cmd.02."MRAID:open" => nil error="URL does not contain MRAID scheme: MRAID:open" domain="org.prebid.mobile" code=700
cmd.03."mraid:" => nil error="Command not found in MRAID url: mraid:" domain="org.prebid.mobile" code=700
cmd.04."mraid" => nil error="URL does not contain MRAID scheme: mraid" domain="org.prebid.mobile" code=700
cmd.05."" => nil error="URL does not contain MRAID scheme: " domain="org.prebid.mobile" code=700
cmd.06."mraid:bad" => nil error="Unrecognized MRAID command bad" domain="org.prebid.mobile" code=700
cmd.07."mraid:expand/foo.com" => command="expand" arguments=["foo.com"] error=nil
cmd.08."mraid:expand/foo.com%20bar" => command="expand" arguments=["foo.com bar"] error=nil
cmd.09."mraid:expand/%" => nil error="Unable to parse MRAID command argument: % on url: mraid:expand/%" domain="org.prebid.mobile" code=700
cmd.10."mraid:expand/%zz" => nil error="Unable to parse MRAID command argument: %zz on url: mraid:expand/%zz" domain="org.prebid.mobile" code=700
cmd.11."mraid:expand/%E0%A4%A" => nil error="Unable to parse MRAID command argument: %E0%A4%A on url: mraid:expand/%E0%A4%A" domain="org.prebid.mobile" code=700
cmd.12."mraid:expand/%C3%A9" => command="expand" arguments=["\u{00E9}"] error=nil
cmd.13."mraid:expand/\u{00E9}" => command="expand" arguments=["\u{00E9}"] error=nil
cmd.14."mraid:expand//" => command="expand" arguments=["", ""] error=nil
cmd.15."mraid:expand/a/b/c" => command="expand" arguments=["a", "b", "c"] error=nil
cmd.16."mraid:/open" => nil error="Command not found in MRAID url: mraid:/open" domain="org.prebid.mobile" code=700
cmd.17."mraid: open" => nil error="Unrecognized MRAID command  open" domain="org.prebid.mobile" code=700
cmd.18."mraid:open/" => command="open" arguments=[""] error=nil
cmd.19."mraid:playVideo/http%3A%2F%2Fa.com%2Fb.mp4" => command="playVideo" arguments=["http://a.com/b.mp4"] error=nil
cmd.20."mraid:onOrientationPropertiesChanged/%7B%22allowOrientationChange%22%3Atrue%7D" => command="onOrientationPropertiesChanged" arguments=["{\"allowOrientationChange\":true}"] error=nil
cmd.21."mraid:ONORIENTATIONPROPERTIESCHANGED" => command="onOrientationPropertiesChanged" arguments=[] error=nil
cmd.22."mraid:\u{0130}" => nil error="Unrecognized MRAID command i\u{0307}" domain="org.prebid.mobile" code=700
cmd.23."mraid:open\u{02BC}" => nil error="Unrecognized MRAID command open\u{02BC}" domain="org.prebid.mobile" code=700
cmd.24."mraid:storePicture" => nil error="Unrecognized MRAID command storepicture" domain="org.prebid.mobile" code=700
cmd.25."mraid:createCalendarEvent" => nil error="Unrecognized MRAID command createcalendarevent" domain="org.prebid.mobile" code=700
cmd.26."mraid:unload" => command="unload" arguments=[] error=nil
cmd.27."mraid:log/%0A" => command="log" arguments=["\n"] error=nil
cmd.28."mraid:expand/%00" => command="expand" arguments=["\u{0000}"] error=nil
cmd.29."mraid:expand/\u{200D}" => command="expand" arguments=["\u{200D}"] error=nil
cmd.30."mraid:expand/a b" => command="expand" arguments=["a b"] error=nil
cmd.31."mraid:expand?x=1" => nil error="Unrecognized MRAID command expand?x=1" domain="org.prebid.mobile" code=700
cmd.32."mraid:open/mraid:close" => command="open" arguments=["mraid:close"] error=nil
cmd.33."mraid:mraid:open" => nil error="Unrecognized MRAID command mraid:open" domain="org.prebid.mobile" code=700
cmd.34."mraid:open\n" => nil error="Unrecognized MRAID command open\n" domain="org.prebid.mobile" code=700
cmd.35."xmraid:" => nil error="Command not found in MRAID url: xmraid:" domain="org.prebid.mobile" code=700
cmd.36."http://a/mraid:" => nil error="Command not found in MRAID url: http://a/mraid:" domain="org.prebid.mobile" code=700
cmd.37."mraid:%6Fpen" => nil error="Unrecognized MRAID command %6fpen" domain="org.prebid.mobile" code=700
cmd.38."mraid:expand/%C3" => nil error="Unable to parse MRAID command argument: %C3 on url: mraid:expand/%C3" domain="org.prebid.mobile" code=700
cmd.39."mraid:PLAYVIDEO/x" => command="playVideo" arguments=["x"] error=nil
cmd.40."mraid:Resize/1/2" => command="resize" arguments=["1", "2"] error=nil
cmd.41."mraid:close/\u{D83D}\u{DE00}" => command="close" arguments=["\u{D83D}\u{DE00}"] error=nil
cmd.42."mraid:expand/%F0%9F%98%80" => command="expand" arguments=["\u{D83D}\u{DE00}"] error=nil
cmd.43."mraid:LOG" => command="log" arguments=[] error=nil
cmd.44."mraid:OnOrientationPropertiesChanged" => command="onOrientationPropertiesChanged" arguments=[] error=nil
cmd.45."mraid:expand/%25" => command="expand" arguments=["%"] error=nil
cmd.46."mraid:expand/%2F" => command="expand" arguments=["/"] error=nil
cmd.47."mraid:op\u{0307}en" => nil error="Unrecognized MRAID command op\u{0307}en" domain="org.prebid.mobile" code=700
cmd.nilurl => nil error="URL is nil" domain="org.prebid.mobile" code=700
cmd.nilerrorpointer => nil
html.00 => "<html><body></body></html>"
html.01 => "<html><body>x</body></html>"
html.02 => "<html><body>x</body></html>"
html.03 => "<html><body></body></html>"
html.04 => "<html><BODY>x</BODY></html>"
html.05 => "<html><body>x</body></html>"
html.06 => "<html><body>x</body></html>"
html.07 => "<html><body><html style=\"a\">x</body></html>"
html.08 => "<html><body><head><script>1</script></head>x</body></html>"
html.09 => "<html><BODY class=a>x</html>"
html.10 => "<html><body><bod>y</body></html>"
html.11 => "<html><body></body></html>"
html.12 => "<html><body><  html></body></html>"
html.13 => "<html><body><html ></body></html>"
html.14 => "<html><body>abcd</body></html>"
html.15 => "<html><bodyx></html>"
html.16 => "<html><body</html>"
html.17 => "<html>\u{0130}<body></html>"
html.18 => "<html><BODY\u{200D}></html>"
html.19 => "<html><!DOCTYPE html><head></head><body>hi</body></html>"
html.20 => "<html><body>line1\nline2\r\n\n\n</body></html>"
html.21 => "<html><body>\u{D83D}\u{DE00}\u{D83D}\u{DE00}\u{D83D}\u{DE00}</body></html>"
html.22 => "<html><body><script src=\"mraid.js\"></script> <div>x</div></body></html>"
html.23 => "<html><body><html style=\"color:red\u{201D}>blah</body></html>"
html.24 => "<html><body><html></body></html>"
html.25 => "<html><body></body></html>"
html.26 => "<html><Body></html>"
html.27 => "<html><body><bo\u{0307}dy></body></html>"
html.28 => "<html><body>%@ %d \\ \"</body></html>"
html.29 => "<html>\u{212A}<BODY></html>"
html.30 => "<html>\u{03A3}<BODY</html>"
html.31 => "<html><body><html\u{200D}>x</body></html>"
html.32 => "<html><BODY>\u{0130}</html>"
html.33 => "<html>\u{1E9E} <Body></html>"
html.34 => "<html><body\n></html>"
html.35 => "<html><body>\nx</body></html>"
html.36 => "<html><body><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</div><div>ab</di</body></html>"
"""#
}
