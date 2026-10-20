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

/// Expected output of `WebViewParityDump.dump()`, one `key => value` line per input.
///
/// These values were captured from the Objective-C `PBMWebView` and `PBMMRAIDController` before they were ported to Swift
/// (Phase 7, agent 2), so they pin the Swift classes to the behavior of the originals, not to themselves. Do not regenerate
/// them from the Swift port. A change here means observable behavior changed.
///
/// Changed on purpose since the capture: the eight `ctl.resize.*.off0` lines whose height (1500, `Int.max`) is taller than the
/// screen are `infinite`. The original compared the height with itself, so it let them through with a negative `y`.
///
/// Masked on purpose: the SDK version, bundle identifier and advertising identifier inside `window.MRAID_ENV`, which differ
/// per build and machine. Left out on purpose: `NaN` frames (UIKit rejects them before they reach the code).
enum WebViewParityExpectations {

    static let expected = #"""
screen => 402.0x874.0
ctl.isMRAIDLink.00."mraid:" => YES
ctl.isMRAIDLink.01."mraid:open" => YES
ctl.isMRAIDLink.02."MRAID:open" => NO
ctl.isMRAIDLink.03."mRaid:open" => NO
ctl.isMRAIDLink.04."mraid" => NO
ctl.isMRAIDLink.05."" => NO
ctl.isMRAIDLink.06." mraid:open" => NO
ctl.isMRAIDLink.07."mraid :open" => NO
ctl.isMRAIDLink.08."mraid:\u{0301}x" => YES
ctl.isMRAIDLink.09."mraid:\u{200D}" => YES
ctl.isMRAIDLink.10."mraid\u{FF1A}open" => NO
ctl.isMRAIDLink.11."\u{FEFF}mraid:open" => NO
ctl.isMRAIDLink.12."xmraid:open" => NO
ctl.isMRAIDLink.13."mraid:mraid:" => YES
ctl.isMRAIDLink.14."mraid:\u{D83D}\u{DE00}" => YES
ctl.isMRAIDLink.15."\u{0130}" => NO
ctl.isMRAIDLink.16."mraid:\u{0130}" => YES
ctl.isMRAIDLink.17."MRAI\u{0130}D:" => NO
ctl.isMRAIDLink.18."mraid;" => NO
ctl.isMRAIDLink.19."mraid:open/%20" => YES
ctl.isMRAIDLink.20."mraid:\n" => YES
ctl.isMRAIDLink.21."mraid:%00" => YES
ctl.isMRAIDLink.22."http://mraid:" => NO
ctl.isMRAIDLink.23."mraid:expand/http://a.com" => YES
ctl.isMRAIDLink.24."mraid\u{0301}:open" => NO
ctl.isMRAIDLink.25."m\u{0301}raid:open" => NO
ctl.isMRAIDLink.26."mraid:\u{D83D}" => YES
ctl.isMRAIDLink.27."mraid\u{200D}:" => NO
ctl.isMRAIDLink.28."MRAID:" => NO
ctl.isMRAIDLink.29."mraid://" => YES
ctl.isMRAIDLink.30."mraid:?" => YES
ctl.isMRAIDLink.31."about:blank" => NO
ctl.isMRAIDLink.32."https://example.com" => NO
ctl.isMRAIDLink.33."tel:123" => NO
ctl.isMRAIDLink.34."mraid:openx" => YES
ctl.isMRAIDLink.35."mraid:" => YES
ctl.isMRAIDLink.36."mraid:\u{00E9}" => YES
ctl.isMRAIDLink.37."mraid:" => YES
ctl.isMRAIDLink.38."mraid: " => YES
ctl.isMRAIDLink.39."mraid:\t" => YES
ctl.isMRAIDLink.40."mraid:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" => YES
ctl.command.00."mraid:open" => url=set command="open" arguments=[]
ctl.command.01."mraid:OPEN" => url=set command="open" arguments=[]
ctl.command.02."MRAID:open" => url=set throws reason="URL does not contain MRAID scheme: MRAID:open"
ctl.command.03."mraid:" => url=set throws reason="Command not found in MRAID url: mraid:"
ctl.command.04."mraid" => url=set throws reason="URL does not contain MRAID scheme: mraid"
ctl.command.05."" => url=set throws reason="URL does not contain MRAID scheme: "
ctl.command.06."mraid:bad" => url=set throws reason="Unrecognized MRAID command bad"
ctl.command.07."mraid:expand/foo.com" => url=set command="expand" arguments=["foo.com"]
ctl.command.08."mraid:expand/foo.com%20bar" => url=set command="expand" arguments=["foo.com bar"]
ctl.command.09."mraid:expand/%" => url=set command="expand" arguments=["%"]
ctl.command.10."mraid:expand/%zz" => url=set command="expand" arguments=["%zz"]
ctl.command.11."mraid:expand/%E0%A4%A" => url=set command="expand" arguments=["%E0%A4%A"]
ctl.command.12."mraid:expand/%C3%A9" => url=set command="expand" arguments=["\u{00E9}"]
ctl.command.13."mraid:expand/\u{00E9}" => url=set command="expand" arguments=["\u{00E9}"]
ctl.command.14."mraid:expand//" => url=set command="expand" arguments=["", ""]
ctl.command.15."mraid:expand/a/b/c" => url=set command="expand" arguments=["a", "b", "c"]
ctl.command.16."mraid:/open" => url=set throws reason="Command not found in MRAID url: mraid:/open"
ctl.command.17."mraid: open" => url=set throws reason="Unrecognized MRAID command %20open"
ctl.command.18."mraid:open/" => url=set command="open" arguments=[""]
ctl.command.19."mraid:playVideo/http%3A%2F%2Fa.com%2Fb.mp4" => url=set command="playVideo" arguments=["http://a.com/b.mp4"]
ctl.command.20."mraid:onOrientationPropertiesChanged/%7B%22allowOrientationChange%22%3Atrue%7D" => url=set command="onOrientationPropertiesChanged" arguments=["{\"allowOrientationChange\":true}"]
ctl.command.21."mraid:ONORIENTATIONPROPERTIESCHANGED" => url=set command="onOrientationPropertiesChanged" arguments=[]
ctl.command.22."mraid:\u{0130}" => url=set throws reason="Unrecognized MRAID command %c4%b0"
ctl.command.23."mraid:open\u{02BC}" => url=set throws reason="Unrecognized MRAID command open%ca%bc"
ctl.command.24."mraid:storePicture" => url=set throws reason="Unrecognized MRAID command storepicture"
ctl.command.25."mraid:createCalendarEvent" => url=set throws reason="Unrecognized MRAID command createcalendarevent"
ctl.command.26."mraid:unload" => url=set command="unload" arguments=[]
ctl.command.27."mraid:log/%0A" => url=set command="log" arguments=["\n"]
ctl.command.28."mraid:expand/%00" => url=set command="expand" arguments=["\u{0000}"]
ctl.command.29."mraid:expand/\u{200D}" => url=set command="expand" arguments=["\u{200D}"]
ctl.command.30."mraid:expand/a b" => url=set command="expand" arguments=["a b"]
ctl.command.31."mraid:expand?x=1" => url=set throws reason="Unrecognized MRAID command expand?x=1"
ctl.command.32."mraid:open/mraid:close" => url=set command="open" arguments=["mraid:close"]
ctl.command.33."mraid:mraid:open" => url=set throws reason="Unrecognized MRAID command mraid:open"
ctl.command.34."mraid:open\n" => url=set throws reason="Unrecognized MRAID command open%0a"
ctl.command.35."xmraid:" => url=set throws reason="Command not found in MRAID url: xmraid:"
ctl.command.36."http://a/mraid:" => url=set throws reason="Command not found in MRAID url: http://a/mraid:"
ctl.command.37."mraid:%6Fpen" => url=set throws reason="Unrecognized MRAID command %6fpen"
ctl.command.38."mraid:expand/%C3" => url=set throws reason="Unable to parse MRAID command argument: %C3 on url: mraid:expand/%C3"
ctl.command.39."mraid:PLAYVIDEO/x" => url=set command="playVideo" arguments=["x"]
ctl.command.40."mraid:Resize/1/2" => url=set command="resize" arguments=["1", "2"]
ctl.command.41."mraid:close/\u{D83D}\u{DE00}" => url=set command="close" arguments=["\u{D83D}\u{DE00}"]
ctl.command.42."mraid:expand/%F0%9F%98%80" => url=set command="expand" arguments=["\u{D83D}\u{DE00}"]
ctl.command.43."mraid:LOG" => url=set command="log" arguments=[]
ctl.command.44."mraid:OnOrientationPropertiesChanged" => url=set command="onOrientationPropertiesChanged" arguments=[]
ctl.command.45."mraid:expand/%25" => url=set command="expand" arguments=["%"]
ctl.command.46."mraid:expand/%2F" => url=set command="expand" arguments=["/"]
ctl.command.47."mraid:op\u{0307}en" => url=set throws reason="Unrecognized MRAID command op%cc%87en"
ctl.command.48."mraid:resize" => url=set command="resize" arguments=[]
ctl.command.49."mraid:close" => url=set command="close" arguments=[]
ctl.command.50."mraid:expand" => url=set command="expand" arguments=[]
ctl.command.51."mraid:playVideo" => url=set command="playVideo" arguments=[]
ctl.command.52."mraid:open/https%3A%2F%2Fa.com%3Fq%3D1%26r%3D2" => url=set command="open" arguments=["https://a.com?q=1&r=2"]
ctl.command.53."mraid:open/a%2Fb" => url=set command="open" arguments=["a/b"]
ctl.command.54."mraid:Unload" => url=set command="unload" arguments=[]
ctl.command.55."mraid:expand/%20" => url=set command="expand" arguments=[" "]
ctl.command.56."mraid:expand/ " => url=set command="expand" arguments=[" "]
ctl.command.57."mraid:log/a/b/c/d/e" => url=set command="log" arguments=["a", "b", "c", "d", "e"]
ctl.command.58."mraid:CLOSE/" => url=set command="close" arguments=[""]
ctl.command.59."mraid:storepicture" => url=set throws reason="Unrecognized MRAID command storepicture"
ctl.command.60."mraid:createcalendarevent" => url=set throws reason="Unrecognized MRAID command createcalendarevent"
ctl.command.61."mraid:%" => url=set throws reason="Unrecognized MRAID command %25"
ctl.command.62."mraid:o%70en" => url=set throws reason="Unrecognized MRAID command o%70en"
ctl.command.63."mraid:\u{00DF}" => url=set throws reason="Unrecognized MRAID command %c3%9f"
ctl.command.64."mraid:open\u{200D}" => url=set throws reason="Unrecognized MRAID command open%e2%80%8d"
ctl.command.nilurl => throws reason="URL is nil"
ctl.resize.orphan.0 => infinite
ctl.resize.orphan.1 => infinite
ctl.resize.orphan.2 => infinite
ctl.resize.orphan.3 => infinite
ctl.resize.orphan.4 => infinite
ctl.resize.orphan.5 => infinite
ctl.resize.orphan.6 => infinite
ctl.resize.nilproperties => infinite
ctl.resize.000.w-9223372036854775808.h-9223372036854775808.x-9223372036854775808.y-9223372036854775808.off0.f0 => infinite
ctl.resize.001.w-9223372036854775808.h-9223372036854775808.x-9223372036854775808.y-9223372036854775808.off1.f1 => infinite
ctl.resize.002.w-9223372036854775808.h-1.x-1000.y-1000.off0.f2 => infinite
ctl.resize.003.w-9223372036854775808.h-1.x-1000.y-1000.off1.f3 => infinite
ctl.resize.004.w-9223372036854775808.h0.x-1.y-1.off0.f4 => infinite
ctl.resize.005.w-9223372036854775808.h0.x-1.y-1.off1.f5 => infinite
ctl.resize.006.w-9223372036854775808.h49.x0.y0.off0.f6 => infinite
ctl.resize.007.w-9223372036854775808.h49.x0.y0.off1.f0 => infinite
ctl.resize.008.w-9223372036854775808.h50.x1.y1.off0.f1 => infinite
ctl.resize.009.w-9223372036854775808.h50.x1.y1.off1.f2 => infinite
ctl.resize.010.w-9223372036854775808.h51.x25.y25.off0.f3 => infinite
ctl.resize.011.w-9223372036854775808.h51.x25.y25.off1.f4 => infinite
ctl.resize.012.w-9223372036854775808.h320.x100.y100.off0.f5 => infinite
ctl.resize.013.w-9223372036854775808.h320.x100.y100.off1.f6 => infinite
ctl.resize.014.w-9223372036854775808.h375.x1000.y1000.off0.f0 => infinite
ctl.resize.015.w-9223372036854775808.h375.x1000.y1000.off1.f1 => infinite
ctl.resize.016.w-9223372036854775808.h700.x9223372036854775807.y9223372036854775807.off0.f2 => infinite
ctl.resize.017.w-9223372036854775808.h700.x9223372036854775807.y9223372036854775807.off1.f3 => infinite
ctl.resize.018.w-1.h-1.x-9223372036854775808.y-1000.off0.f4 => infinite
ctl.resize.019.w-1.h-1.x-9223372036854775808.y-1000.off1.f5 => infinite
ctl.resize.020.w-1.h0.x-1000.y-1.off0.f6 => infinite
ctl.resize.021.w-1.h0.x-1000.y-1.off1.f0 => infinite
ctl.resize.022.w-1.h49.x-1.y0.off0.f1 => infinite
ctl.resize.023.w-1.h49.x-1.y0.off1.f2 => infinite
ctl.resize.024.w-1.h50.x0.y1.off0.f3 => infinite
ctl.resize.025.w-1.h50.x0.y1.off1.f4 => infinite
ctl.resize.026.w-1.h51.x1.y25.off0.f5 => infinite
ctl.resize.027.w-1.h51.x1.y25.off1.f6 => infinite
ctl.resize.028.w-1.h320.x25.y100.off0.f0 => infinite
ctl.resize.029.w-1.h320.x25.y100.off1.f1 => infinite
ctl.resize.030.w-1.h375.x100.y1000.off0.f2 => infinite
ctl.resize.031.w-1.h375.x100.y1000.off1.f3 => infinite
ctl.resize.032.w-1.h700.x1000.y9223372036854775807.off0.f4 => infinite
ctl.resize.033.w-1.h700.x1000.y9223372036854775807.off1.f5 => infinite
ctl.resize.034.w-1.h1500.x9223372036854775807.y-9223372036854775808.off0.f6 => infinite
ctl.resize.035.w-1.h1500.x9223372036854775807.y-9223372036854775808.off1.f0 => infinite
ctl.resize.036.w0.h0.x-9223372036854775808.y-1.off0.f1 => infinite
ctl.resize.037.w0.h0.x-9223372036854775808.y-1.off1.f2 => infinite
ctl.resize.038.w0.h49.x-1000.y0.off0.f3 => infinite
ctl.resize.039.w0.h49.x-1000.y0.off1.f4 => infinite
ctl.resize.040.w0.h50.x-1.y1.off0.f5 => infinite
ctl.resize.041.w0.h50.x-1.y1.off1.f6 => infinite
ctl.resize.042.w0.h51.x0.y25.off0.f0 => infinite
ctl.resize.043.w0.h51.x0.y25.off1.f1 => infinite
ctl.resize.044.w0.h320.x1.y100.off0.f2 => infinite
ctl.resize.045.w0.h320.x1.y100.off1.f3 => infinite
ctl.resize.046.w0.h375.x25.y1000.off0.f4 => infinite
ctl.resize.047.w0.h375.x25.y1000.off1.f5 => infinite
ctl.resize.048.w0.h700.x100.y9223372036854775807.off0.f6 => infinite
ctl.resize.049.w0.h700.x100.y9223372036854775807.off1.f0 => infinite
ctl.resize.050.w0.h1500.x1000.y-9223372036854775808.off0.f1 => infinite
ctl.resize.051.w0.h1500.x1000.y-9223372036854775808.off1.f2 => infinite
ctl.resize.052.w0.h9223372036854775807.x9223372036854775807.y-1000.off0.f3 => infinite
ctl.resize.053.w0.h9223372036854775807.x9223372036854775807.y-1000.off1.f4 => infinite
ctl.resize.054.w49.h49.x-9223372036854775808.y0.off0.f5 => infinite
ctl.resize.055.w49.h49.x-9223372036854775808.y0.off1.f6 => infinite
ctl.resize.056.w49.h50.x-1000.y1.off0.f0 => infinite
ctl.resize.057.w49.h50.x-1000.y1.off1.f1 => infinite
ctl.resize.058.w49.h51.x-1.y25.off0.f2 => infinite
ctl.resize.059.w49.h51.x-1.y25.off1.f3 => infinite
ctl.resize.060.w49.h320.x0.y100.off0.f4 => infinite
ctl.resize.061.w49.h320.x0.y100.off1.f5 => infinite
ctl.resize.062.w49.h375.x1.y1000.off0.f6 => infinite
ctl.resize.063.w49.h375.x1.y1000.off1.f0 => infinite
ctl.resize.064.w49.h700.x25.y9223372036854775807.off0.f1 => infinite
ctl.resize.065.w49.h700.x25.y9223372036854775807.off1.f2 => infinite
ctl.resize.066.w49.h1500.x100.y-9223372036854775808.off0.f3 => infinite
ctl.resize.067.w49.h1500.x100.y-9223372036854775808.off1.f4 => infinite
ctl.resize.068.w49.h9223372036854775807.x1000.y-1000.off0.f5 => infinite
ctl.resize.069.w49.h9223372036854775807.x1000.y-1000.off1.f6 => infinite
ctl.resize.070.w49.h-9223372036854775808.x9223372036854775807.y-1.off0.f0 => infinite
ctl.resize.071.w49.h-9223372036854775808.x9223372036854775807.y-1.off1.f1 => infinite
ctl.resize.072.w50.h50.x-9223372036854775808.y1.off0.f2 => rect(352.000000,0.000000,50.000000,50.000000)
ctl.resize.073.w50.h50.x-9223372036854775808.y1.off1.f3 => infinite
ctl.resize.074.w50.h51.x-1000.y25.off0.f4 => rect(352.000000,0.000000,50.000000,51.000000)
ctl.resize.075.w50.h51.x-1000.y25.off1.f5 => infinite
ctl.resize.076.w50.h320.x-1.y100.off0.f6 => rect(0.000000,80.000000,50.000000,320.000000)
ctl.resize.077.w50.h320.x-1.y100.off1.f0 => rect(24.000000,125.000000,50.000000,320.000000)
ctl.resize.078.w50.h375.x0.y1000.off0.f1 => rect(0.000000,499.000000,50.000000,375.000000)
ctl.resize.079.w50.h375.x0.y1000.off1.f2 => infinite
ctl.resize.080.w50.h700.x1.y9223372036854775807.off0.f3 => rect(301.000000,0.000000,50.000000,700.000000)
ctl.resize.081.w50.h700.x1.y9223372036854775807.off1.f4 => infinite
ctl.resize.082.w50.h1500.x25.y-9223372036854775808.off0.f5 => infinite
ctl.resize.083.w50.h1500.x25.y-9223372036854775808.off1.f6 => infinite
ctl.resize.084.w50.h9223372036854775807.x100.y-1000.off0.f0 => infinite
ctl.resize.085.w50.h9223372036854775807.x100.y-1000.off1.f1 => infinite
ctl.resize.086.w50.h-9223372036854775808.x1000.y-1.off0.f2 => infinite
ctl.resize.087.w50.h-9223372036854775808.x1000.y-1.off1.f3 => infinite
ctl.resize.088.w50.h-1.x9223372036854775807.y0.off0.f4 => infinite
ctl.resize.089.w50.h-1.x9223372036854775807.y0.off1.f5 => infinite
ctl.resize.090.w51.h51.x-9223372036854775808.y25.off0.f6 => rect(351.000000,5.000000,51.000000,51.000000)
ctl.resize.091.w51.h51.x-9223372036854775808.y25.off1.f0 => infinite
ctl.resize.092.w51.h320.x-1000.y100.off0.f1 => rect(0.000000,100.000000,51.000000,320.000000)
ctl.resize.093.w51.h320.x-1000.y100.off1.f2 => infinite
ctl.resize.094.w51.h375.x-1.y1000.off0.f3 => rect(299.000000,499.000000,51.000000,375.000000)
ctl.resize.095.w51.h375.x-1.y1000.off1.f4 => infinite
ctl.resize.096.w51.h700.x0.y9223372036854775807.off0.f5 => rect(10.000000,0.000000,51.000000,700.000000)
ctl.resize.097.w51.h700.x0.y9223372036854775807.off1.f6 => infinite
ctl.resize.098.w51.h1500.x1.y-9223372036854775808.off0.f0 => infinite
ctl.resize.099.w51.h1500.x1.y-9223372036854775808.off1.f1 => infinite
ctl.resize.100.w51.h9223372036854775807.x25.y-1000.off0.f2 => infinite
ctl.resize.101.w51.h9223372036854775807.x25.y-1000.off1.f3 => infinite
ctl.resize.102.w51.h-9223372036854775808.x100.y-1.off0.f4 => infinite
ctl.resize.103.w51.h-9223372036854775808.x100.y-1.off1.f5 => infinite
ctl.resize.104.w51.h-1.x1000.y0.off0.f6 => infinite
ctl.resize.105.w51.h-1.x1000.y0.off1.f0 => infinite
ctl.resize.106.w51.h0.x9223372036854775807.y1.off0.f1 => infinite
ctl.resize.107.w51.h0.x9223372036854775807.y1.off1.f2 => infinite
ctl.resize.108.w320.h320.x-9223372036854775808.y100.off0.f3 => rect(0.000000,554.000000,320.000000,320.000000)
ctl.resize.109.w320.h320.x-9223372036854775808.y100.off1.f4 => infinite
ctl.resize.110.w320.h375.x-1000.y1000.off0.f5 => rect(0.000000,499.000000,320.000000,375.000000)
ctl.resize.111.w320.h375.x-1000.y1000.off1.f6 => infinite
ctl.resize.112.w320.h700.x-1.y9223372036854775807.off0.f0 => rect(24.000000,0.000000,320.000000,700.000000)
ctl.resize.113.w320.h700.x-1.y9223372036854775807.off1.f1 => infinite
ctl.resize.114.w320.h1500.x0.y-9223372036854775808.off0.f2 => infinite
ctl.resize.115.w320.h1500.x0.y-9223372036854775808.off1.f3 => infinite
ctl.resize.116.w320.h9223372036854775807.x1.y-1000.off0.f4 => infinite
ctl.resize.117.w320.h9223372036854775807.x1.y-1000.off1.f5 => infinite
ctl.resize.118.w320.h-9223372036854775808.x25.y-1.off0.f6 => infinite
ctl.resize.119.w320.h-9223372036854775808.x25.y-1.off1.f0 => infinite
ctl.resize.120.w320.h-1.x100.y0.off0.f1 => infinite
ctl.resize.121.w320.h-1.x100.y0.off1.f2 => infinite
ctl.resize.122.w320.h0.x1000.y1.off0.f3 => infinite
ctl.resize.123.w320.h0.x1000.y1.off1.f4 => infinite
ctl.resize.124.w320.h49.x9223372036854775807.y25.off0.f5 => infinite
ctl.resize.125.w320.h49.x9223372036854775807.y25.off1.f6 => infinite
ctl.resize.126.w375.h375.x-9223372036854775808.y1000.off0.f0 => rect(0.000000,499.000000,375.000000,375.000000)
ctl.resize.127.w375.h375.x-9223372036854775808.y1000.off1.f1 => infinite
ctl.resize.128.w375.h700.x-1000.y9223372036854775807.off0.f2 => rect(0.000000,174.000000,375.000000,700.000000)
ctl.resize.129.w375.h700.x-1000.y9223372036854775807.off1.f3 => infinite
ctl.resize.130.w375.h1500.x-1.y-9223372036854775808.off0.f4 => infinite
ctl.resize.131.w375.h1500.x-1.y-9223372036854775808.off1.f5 => infinite
ctl.resize.132.w375.h9223372036854775807.x0.y-1000.off0.f6 => infinite
ctl.resize.133.w375.h9223372036854775807.x0.y-1000.off1.f0 => infinite
ctl.resize.134.w375.h-9223372036854775808.x1.y-1.off0.f1 => infinite
ctl.resize.135.w375.h-9223372036854775808.x1.y-1.off1.f2 => infinite
ctl.resize.136.w375.h-1.x25.y0.off0.f3 => infinite
ctl.resize.137.w375.h-1.x25.y0.off1.f4 => infinite
ctl.resize.138.w375.h0.x100.y1.off0.f5 => infinite
ctl.resize.139.w375.h0.x100.y1.off1.f6 => infinite
ctl.resize.140.w375.h49.x1000.y25.off0.f0 => infinite
ctl.resize.141.w375.h49.x1000.y25.off1.f1 => infinite
ctl.resize.142.w375.h50.x9223372036854775807.y100.off0.f2 => rect(27.000000,0.000000,375.000000,50.000000)
ctl.resize.143.w375.h50.x9223372036854775807.y100.off1.f3 => infinite
ctl.resize.144.w700.h700.x-9223372036854775808.y9223372036854775807.off0.f4 => infinite
ctl.resize.145.w700.h700.x-9223372036854775808.y9223372036854775807.off1.f5 => infinite
ctl.resize.146.w700.h1500.x-1000.y-9223372036854775808.off0.f6 => infinite
ctl.resize.147.w700.h1500.x-1000.y-9223372036854775808.off1.f0 => infinite
ctl.resize.148.w700.h9223372036854775807.x-1.y-1000.off0.f1 => infinite
ctl.resize.149.w700.h9223372036854775807.x-1.y-1000.off1.f2 => infinite
ctl.resize.150.w700.h-9223372036854775808.x0.y-1.off0.f3 => infinite
ctl.resize.151.w700.h-9223372036854775808.x0.y-1.off1.f4 => infinite
ctl.resize.152.w700.h-1.x1.y0.off0.f5 => infinite
ctl.resize.153.w700.h-1.x1.y0.off1.f6 => infinite
ctl.resize.154.w700.h0.x25.y1.off0.f0 => infinite
ctl.resize.155.w700.h0.x25.y1.off1.f1 => infinite
ctl.resize.156.w700.h49.x100.y25.off0.f2 => infinite
ctl.resize.157.w700.h49.x100.y25.off1.f3 => infinite
ctl.resize.158.w700.h50.x1000.y100.off0.f4 => infinite
ctl.resize.159.w700.h50.x1000.y100.off1.f5 => infinite
ctl.resize.160.w700.h51.x9223372036854775807.y1000.off0.f6 => infinite
ctl.resize.161.w700.h51.x9223372036854775807.y1000.off1.f0 => infinite
ctl.resize.162.w1500.h1500.x-9223372036854775808.y-9223372036854775808.off0.f1 => infinite
ctl.resize.163.w1500.h1500.x-9223372036854775808.y-9223372036854775808.off1.f2 => infinite
ctl.resize.164.w1500.h9223372036854775807.x-1000.y-1000.off0.f3 => infinite
ctl.resize.165.w1500.h9223372036854775807.x-1000.y-1000.off1.f4 => infinite
ctl.resize.166.w1500.h-9223372036854775808.x-1.y-1.off0.f5 => infinite
ctl.resize.167.w1500.h-9223372036854775808.x-1.y-1.off1.f6 => infinite
ctl.resize.168.w1500.h-1.x0.y0.off0.f0 => infinite
ctl.resize.169.w1500.h-1.x0.y0.off1.f1 => infinite
ctl.resize.170.w1500.h0.x1.y1.off0.f2 => infinite
ctl.resize.171.w1500.h0.x1.y1.off1.f3 => infinite
ctl.resize.172.w1500.h49.x25.y25.off0.f4 => infinite
ctl.resize.173.w1500.h49.x25.y25.off1.f5 => infinite
ctl.resize.174.w1500.h50.x100.y100.off0.f6 => infinite
ctl.resize.175.w1500.h50.x100.y100.off1.f0 => infinite
ctl.resize.176.w1500.h51.x1000.y1000.off0.f1 => infinite
ctl.resize.177.w1500.h51.x1000.y1000.off1.f2 => infinite
ctl.resize.178.w1500.h320.x9223372036854775807.y9223372036854775807.off0.f3 => infinite
ctl.resize.179.w1500.h320.x9223372036854775807.y9223372036854775807.off1.f4 => infinite
ctl.resize.180.w9223372036854775807.h9223372036854775807.x-9223372036854775808.y-1000.off0.f5 => infinite
ctl.resize.181.w9223372036854775807.h9223372036854775807.x-9223372036854775808.y-1000.off1.f6 => infinite
ctl.resize.182.w9223372036854775807.h-9223372036854775808.x-1000.y-1.off0.f0 => infinite
ctl.resize.183.w9223372036854775807.h-9223372036854775808.x-1000.y-1.off1.f1 => infinite
ctl.resize.184.w9223372036854775807.h-1.x-1.y0.off0.f2 => infinite
ctl.resize.185.w9223372036854775807.h-1.x-1.y0.off1.f3 => infinite
ctl.resize.186.w9223372036854775807.h0.x0.y1.off0.f4 => infinite
ctl.resize.187.w9223372036854775807.h0.x0.y1.off1.f5 => infinite
ctl.resize.188.w9223372036854775807.h49.x1.y25.off0.f6 => infinite
ctl.resize.189.w9223372036854775807.h49.x1.y25.off1.f0 => infinite
ctl.resize.190.w9223372036854775807.h50.x25.y100.off0.f1 => infinite
ctl.resize.191.w9223372036854775807.h50.x25.y100.off1.f2 => infinite
ctl.resize.192.w9223372036854775807.h51.x100.y1000.off0.f3 => infinite
ctl.resize.193.w9223372036854775807.h51.x100.y1000.off1.f4 => infinite
ctl.resize.194.w9223372036854775807.h320.x1000.y9223372036854775807.off0.f5 => infinite
ctl.resize.195.w9223372036854775807.h320.x1000.y9223372036854775807.off1.f6 => infinite
ctl.resize.196.w9223372036854775807.h375.x9223372036854775807.y-9223372036854775808.off0.f0 => infinite
ctl.resize.197.w9223372036854775807.h375.x9223372036854775807.y-9223372036854775808.off1.f1 => infinite
ctl.resize.big.0.offscreen => infinite
ctl.resize.big.0.onscreen => rect(0.000000,0.000000,100.000000,100.000000)
ctl.resize.big.1.offscreen => infinite
ctl.resize.big.1.onscreen => rect(0.000000,0.000000,100.000000,100.000000)
ctl.resize.big.2.offscreen => infinite
ctl.resize.big.2.onscreen => rect(0.000000,0.000000,100.000000,100.000000)
ctl.resize.big.3.offscreen => infinite
ctl.resize.big.3.onscreen => rect(0.000000,0.000000,100.000000,100.000000)
ctl.resize.big.4.offscreen => infinite
ctl.resize.big.4.onscreen => rect(0.000000,0.000000,100.000000,100.000000)
web.anyToJSONDict.nil => nil
web.anyToJSONDict.00 => nil
web.anyToJSONDict.01 => nil
web.anyToJSONDict.02 => nil
web.anyToJSONDict.03 => nil
web.anyToJSONDict.04 => {}
web.anyToJSONDict.05 => {}
web.anyToJSONDict.06 => {"a"=num:q:1}
web.anyToJSONDict.07 => {"a"=num:d:1}
web.anyToJSONDict.08 => {"a"=bool:true, "b"=null, "c"=[num:q:1, num:q:2, {"d"=str:"e"}], "f"={"g"={}}}
web.anyToJSONDict.09 => {"height"=num:q:250, "width"=num:q:300}
web.anyToJSONDict.10 => {"width"=str:"300"}
web.anyToJSONDict.11 => {"a"=num:q:1}
web.anyToJSONDict.12 => nil
web.anyToJSONDict.13 => nil
web.anyToJSONDict.14 => nil
web.anyToJSONDict.15 => nil
web.anyToJSONDict.16 => nil
web.anyToJSONDict.17 => nil
web.anyToJSONDict.18 => {"\u{00E9}"=str:"\u{00FC}"}
web.anyToJSONDict.19 => {"a"=str:"\u{00E9}"}
web.anyToJSONDict.20 => {"a"=str:"\u{D83D}\u{DE00}"}
web.anyToJSONDict.21 => nil
web.anyToJSONDict.22 => nil
web.anyToJSONDict.23 => {}
web.anyToJSONDict.24 => {}
web.anyToJSONDict.25 => {}
web.anyToJSONDict.26 => nil
web.anyToJSONDict.27 => nil
web.anyToJSONDict.28 => nil
web.anyToJSONDict.29 => nil
web.anyToJSONDict.30 => {"a"=num:Q:12345678901234567890}
web.anyToJSONDict.31 => {"a"=num:q:0}
web.anyToJSONDict.32 => {"a"=num:d:0.1}
web.anyToJSONDict.33 => {"a"=num:d:100}
web.anyToJSONDict.34 => {"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"={"a"=num:q:1}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
web.anyToJSONDict.35 => nil
web.anyToJSONDict.36 => nil
web.anyToJSONDict.37 => nil
web.anyToJSONDict.38 => nil
web.anyToJSONDict.39 => nil
web.anyToJSONDict.40 => nil
web.anyToJSONDict.41 => nil
web.anyToJSONDict.42 => {"a"=str:"b"}
web.anyToJSONDict.43 => {"a"=str:"b"}
web.anyToJSONDict.44 => {"a"=str:"\u{0000}"}
web.anyToJSONDict.45 => nil
web.anyToJSONDict.46 => nil
web.anyToJSONDict.47 => nil
web.anyToJSONDict.48 => nil
web.anyToJSONDict.49 => {"a"={"b"=[]}}
web.anyToJSONDict.50 => {"allowOffscreen"=bool:false, "height"=num:q:2, "offsetX"=num:q:-5, "offsetY"=num:q:6, "width"=num:q:1}
web.anyToJSONDict.51 => {"height"=num:d:2.1, "width"=num:d:1.9}
web.anyToJSONDict.52 => {"height"=num:d:2, "width"=num:d:100}
web.anyToJSONDict.53 => {"height"=num:q:0, "width"=num:q:-1}
web.webViewStateDescription.0 => "unloaded"
web.webViewStateDescription.1 => "loading"
web.webViewStateDescription.2 => "loaded"
web.isVisibleView.nil => NO
web.isVisibleView.plain => NO
web.isVisibleView.window => NO
web.isVisibleView.parentNoWindow => NO
web.isVisibleView.windowChildZeroFrame => NO
web.isVisibleView.unitFrame => YES
web.isVisibleView.outOfRange => NO
web.isVisibleView.complexHierarchy => YES
web.isVisibleView.hidden => NO
web.isVisibleView.alphaZero => YES
web.orientationLocked.nilvc => NO
web.orientationLocked.mask00 => YES
web.orientationLocked.mask01 => YES
web.orientationLocked.mask02 => YES
web.orientationLocked.mask03 => YES
web.orientationLocked.mask04 => YES
web.orientationLocked.mask05 => YES
web.orientationLocked.mask06 => YES
web.orientationLocked.mask07 => YES
web.orientationLocked.mask08 => YES
web.orientationLocked.mask09 => YES
web.orientationLocked.mask10 => NO
web.orientationLocked.mask11 => NO
web.orientationLocked.mask12 => NO
web.orientationLocked.mask13 => NO
web.orientationLocked.mask14 => NO
web.orientationLocked.mask15 => NO
web.orientationLocked.mask16 => YES
web.orientationLocked.mask17 => YES
web.orientationLocked.mask18 => NO
web.orientationLocked.mask19 => NO
web.orientationLocked.mask20 => NO
web.orientationLocked.mask21 => NO
web.orientationLocked.mask22 => NO
web.orientationLocked.mask23 => NO
web.orientationLocked.mask24 => YES
web.orientationLocked.mask25 => YES
web.orientationLocked.mask26 => NO
web.orientationLocked.mask27 => NO
web.orientationLocked.mask28 => NO
web.orientationLocked.mask29 => NO
web.orientationLocked.mask30 => NO
web.orientationLocked.mask31 => NO
web.mraidEnv.coppa.0 => "window.MRAID_ENV = {\n  version: '3.0',\n  sdk: 'prebid-mobile-sdk',\n  sdkVersion: '<sdk>',\n  appId: '<app>',\n  ifa: '<ifa>',\n  limitAdTracking: true,\n  coppa: false}"
web.mraidEnv.coppa.1 => "window.MRAID_ENV = {\n  version: '3.0',\n  sdk: 'prebid-mobile-sdk',\n  sdkVersion: '<sdk>',\n  appId: '<app>',\n  ifa: '<ifa>',\n  limitAdTracking: true,\n  coppa: false}"
web.mraidEnv.coppa.2 => "window.MRAID_ENV = {\n  version: '3.0',\n  sdk: 'prebid-mobile-sdk',\n  sdkVersion: '<sdk>',\n  appId: '<app>',\n  ifa: '<ifa>',\n  limitAdTracking: true,\n  coppa: true}"
web.mraidEnv.coppa.3 => "window.MRAID_ENV = {\n  version: '3.0',\n  sdk: 'prebid-mobile-sdk',\n  sdkVersion: '<sdk>',\n  appId: '<app>',\n  ifa: '<ifa>',\n  limitAdTracking: true,\n  coppa: false}"
web.mraidEnv.coppa.4 => "window.MRAID_ENV = {\n  version: '3.0',\n  sdk: 'prebid-mobile-sdk',\n  sdkVersion: '<sdk>',\n  appId: '<app>',\n  ifa: '<ifa>',\n  limitAdTracking: true,\n  coppa: true}"
web.mraidEnv.coppa.5 => "window.MRAID_ENV = {\n  version: '3.0',\n  sdk: 'prebid-mobile-sdk',\n  sdkVersion: '<sdk>',\n  appId: '<app>',\n  ifa: '<ifa>',\n  limitAdTracking: true,\n  coppa: false}"
"""#

    /// Captured from the Objective-C `-[PBMWebView MRAID_getExpandProperties:]` and `-[PBMWebView MRAID_getResizeProperties:]`
    /// by stubbing `window.mraid` with the given JavaScript expression. One entry per input: `key => javascript :: result`.
    /// The inputs on which the Objective-C code crashed ("unrecognized selector") are in
    /// `WebViewParityTests.testUnsupportedValueTypesInJSPropertiesAreRejected`.
    static let javaScriptProperties = #"""
probe.expand.00 => {width:300,height:250} :: width=300 height=250
probe.expand.01 => {width:'300',height:'250'} :: width=300 height=250
probe.expand.02 => {width:300.7,height:250.2} :: width=300 height=250
probe.expand.03 => {width:-5.9,height:1e30} :: width=-5 height=9223372036854775807
probe.expand.04 => {width:true,height:false} :: width=1 height=0
probe.expand.05 => {width:'abc',height:'12abc'} :: width=0 height=12
probe.expand.06 => {height:250} :: nil
probe.expand.07 => {width:'  42',height:'+7'} :: width=42 height=7
probe.expand.08 => {width:'1e3',height:'0x10'} :: width=1 height=0
probe.expand.09 => {width:1e300,height:-1e300} :: width=9223372036854775807 height=-9223372036854775808
probe.expand.10 => null :: nil
probe.expand.11 => {} :: nil
probe.expand.12 => [1,2] :: nil
probe.expand.13 => 'str' :: nil
probe.expand.14 => 7 :: nil
probe.expand.15 => {width:'',height:''} :: width=0 height=0
probe.expand.16 => {width:'-0',height:'9999999999999999999999'} :: width=0 height=9223372036854775807
probe.expand.17 => {width:2147483648,height:-2147483649} :: width=2147483648 height=-2147483649
probe.expand.18 => {width:4294967296,height:9007199254740993} :: width=4294967296 height=9007199254740992
probe.expand.19 => {width:0.5,height:-0.5} :: width=0 height=0
probe.expand.20 => {width:'0.9',height:'-0.9'} :: width=0 height=0
probe.expand.21 => {width:300,height:250,extra:1} :: width=300 height=250
probe.expand.22 => undefined :: nil
probe.expand.23 => {width:1,height:undefined} :: nil
probe.resize.00 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:true} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.01 => {width:'300',height:'250',offsetX:'-1',offsetY:'2',allowOffscreen:'true'} :: width=300 height=250 offsetX=-1 offsetY=2 allowOffscreen=1
probe.resize.02 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:false} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.03 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'yes'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.04 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'no'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.05 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'0'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.06 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'1'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.07 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'maybe'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.08 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:''} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.09 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'TRUE'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.10 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:' true'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.11 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'t'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.12 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:'-1'} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.13 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:1} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.14 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:0} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.15 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:2} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.16 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:0.5} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=1
probe.resize.17 => {width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:-0.0} :: width=300 height=250 offsetX=1 offsetY=2 allowOffscreen=0
probe.resize.18 => {width:300,height:250,offsetX:1,offsetY:2} :: nil
probe.resize.19 => {width:300,height:250,offsetX:1,allowOffscreen:true} :: nil
probe.resize.20 => {width:300.9,height:250.9,offsetX:-1.9,offsetY:2.9,allowOffscreen:true} :: width=300 height=250 offsetX=-1 offsetY=2 allowOffscreen=1
probe.resize.21 => {width:1e300,height:-1e300,offsetX:1e300,offsetY:-1e300,allowOffscreen:true} :: width=9223372036854775807 height=-9223372036854775808 offsetX=9223372036854775807 offsetY=-9223372036854775808 allowOffscreen=1
probe.resize.22 => {width:'x',height:'y',offsetX:'z',offsetY:'w',allowOffscreen:'q'} :: width=0 height=0 offsetX=0 offsetY=0 allowOffscreen=0
probe.resize.23 => null :: nil
probe.resize.24 => {} :: nil
probe.resize.25 => {width:1,height:2,offsetX:3,offsetY:4,allowOffscreen:true,extra:5} :: width=1 height=2 offsetX=3 offsetY=4 allowOffscreen=1
"""#
}
