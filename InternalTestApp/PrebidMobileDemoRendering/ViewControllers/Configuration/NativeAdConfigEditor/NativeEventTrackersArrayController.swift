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
import Eureka
import PrebidMobile

class NativeEventTrackersArrayController : FormViewController {
    var nativeAdConfig: NativeAdConfiguration!
    
    private var eventTrackersSection: MultivaluedSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Trackers"
        
        buildForm()
    }
    
    func buildForm() {
        func makeEventTrackerRow(eventTracker: NativeEventTracker) -> ButtonRowOf<NativeEventTracker> {
            return ButtonRowOf<NativeEventTracker> { row in
                row.value = eventTracker
                row.title = try! eventTracker.toJsonString()
            }
            .onCellSelection { [weak self] cell, row in
                let editor = NativeEventTrackerController()
                editor.eventTracker = row.value
                self?.navigationController?.pushViewController(editor, animated: true)
            }
        }
        
        eventTrackersSection = MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                               header: "eventTrackers",
                                               footer: ".Insert adds a 'Add Item' (Add New Tag) button row as last cell.") { section in
            section.addButtonProvider = { _ in
                ButtonRow() { row in
                    row.title = "Add EventTracker"
                }
            }
            section.multivaluedRowToInsertAt = { _ in
                makeEventTrackerRow(eventTracker: NativeEventTracker(event: NativeEventType.impression.rawValue, methods: []))
            }
            for nextEventTracker in nativeAdConfig.eventtrackers! {
                section <<< makeEventTrackerRow(eventTracker: nextEventTracker)
            }
        }
        
        form
            +++ eventTrackersSection
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventTrackersSection.allRows.compactMap { $0 as? ButtonRowOf<NativeEventTracker> }.forEach {
            $0.title = try! $0.value!.toJsonString()
            $0.updateCell()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nativeAdConfig.eventtrackers = eventTrackersSection.values().compactMap { $0 as? NativeEventTracker }
    }
}
