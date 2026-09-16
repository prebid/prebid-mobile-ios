/*   Copyright 2018-2021 Prebid.org, Inc.

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

// Swift-facing closure typealiases for the ObjC block typedefs declared in
// `PBMURLOpenResultHandlerBlock.h`, `PBMTrackingURLVisitorBlock.h`,
// `PBMExternalURLOpenerBlock.h` and `PBMURLOpenAttempterBlock.h`.
// Block typedefs bridge structurally rather than nominally (playbook Gap S2.3-B), so those
// headers stay ObjC while `PBMDeepLinkPlusHelper.m` still uses them; they retire together
// once that file is ported, and this file becomes the sole declaration site.

@_spi(PBMInternal) public
typealias URLOpenResultHandlerBlock = (_ urlOpened: Bool) -> Void

@_spi(PBMInternal) public
typealias TrackingURLVisitorBlock = (_ trackingUrlStrings: [String]) -> Void

@_spi(PBMInternal) public
typealias ExternalURLOpenerBlock = (
    _ url: URL,
    _ completion: @escaping URLOpenResultHandlerBlock,
    _ onClickthroughExitBlock: VoidBlock?
) -> Void

// will return ('nop', nil) container if passed false; otherwise -- will return completion handlers.
@_spi(PBMInternal) public
typealias CanOpenURLResultHandlerBlock = (_ willOpenURL: Bool) -> ExternalURLOpenCallbacks

// pass 'true' to 'compatibilityCheckHandler' to get URL handling completion block;
// if incompatible, call 'compatibilityCheckHandler' with false.
@_spi(PBMInternal) public
typealias URLOpenAttempterBlock = (_ url: URL, _ compatibilityCheckHandler: @escaping CanOpenURLResultHandlerBlock) -> Void
