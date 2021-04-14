//
//  NativeEventTrackersArrayController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

class NativeEventTrackersArrayController : FormViewController {
    var nativeAdConfig: OXANativeAdConfiguration!
    
    private var eventTrackersSection: MultivaluedSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Trackers"
        
        buildForm()
    }
    
    func buildForm() {
        func makeEventTrackerRow(eventTracker: OXANativeEventTracker) -> ButtonRowOf<OXANativeEventTracker> {
            return ButtonRowOf<OXANativeEventTracker> { row in
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
                makeEventTrackerRow(eventTracker: OXANativeEventTracker(event: .impression, methods: []))
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
        eventTrackersSection.allRows.compactMap { $0 as? ButtonRowOf<OXANativeEventTracker> }.forEach {
            $0.title = try! $0.value!.toJsonString()
            $0.updateCell()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nativeAdConfig.eventtrackers = eventTrackersSection.values().compactMap { $0 as? OXANativeEventTracker }
    }
}
