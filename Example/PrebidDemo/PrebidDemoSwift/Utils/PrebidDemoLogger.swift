/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

import OSLog
import UIKit

struct PrebidDemoLogger {
    static let shared = PrebidDemoLogger()

    private let logger = Logger()

    func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
        UITestAdStatus.shared.reportFailure(message)
    }
}

/// Makes SDK and ad-server failures observable to UI tests without affecting the demo UI.
final class UITestAdStatus {
    static let shared = UITestAdStatus()
    static let accessibilityIdentifier = "prebid-demo-ad-status"

    private weak var statusView: UIView?

    private var isEnabled: Bool {
        CommandLine.arguments.contains("-uiTesting")
    }

    func reset() {
        guard isEnabled else { return }

        DispatchQueue.main.async { [weak self] in
            self?.updateStatus("loading")
        }
    }

    func reportFailure(_ message: String) {
        guard isEnabled else { return }

        DispatchQueue.main.async { [weak self] in
            self?.updateStatus("failed: \(message)")
        }
    }

    private func updateStatus(_ status: String) {
        guard let statusView = statusView ?? installStatusView() else { return }
        statusView.accessibilityValue = status
    }

    private func installStatusView() -> UIView? {
        guard let window = UIApplication.shared.getKeyWindow() else { return nil }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = Self.accessibilityIdentifier
        view.accessibilityLabel = "Ad load status"
        view.accessibilityValue = "loading"
        window.addSubview(view)
        statusView = view
        return view
    }
}
