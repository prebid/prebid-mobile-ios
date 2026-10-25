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

import UIKit

class PrebidMultiformatConfigurationController: BaseConfigurationController {
    private(set) var includeBanner = true
    private(set) var includeVideo = true
    private(set) var includeNative = true
    private var loadButton: UIButton?

    override var loadSection: FormSection {
        let button = makeLoadButton()
        loadButton = button
        let banner = checkRow("Banner") { [weak self] in self?.includeBanner = $0 }
        let video = checkRow("Video") { [weak self] in self?.includeVideo = $0 }
        let native = checkRow("Native") { [weak self] in self?.includeNative = $0 }
        return FormSection("Ad Formats", rows: [banner, video, native], footer: button)
    }

    private func checkRow(_ title: String, onChange: @escaping (Bool) -> Void) -> FormRow {
        let row = FormRow(title, kind: .checkmark, isOn: true)
        row.onToggle = { [weak self] value in
            onChange(value)
            guard let self = self else { return }
            self.loadButton?.isEnabled = [self.includeBanner, self.includeVideo, self.includeNative].filter { $0 }.count >= 2
        }
        return row
    }
}
