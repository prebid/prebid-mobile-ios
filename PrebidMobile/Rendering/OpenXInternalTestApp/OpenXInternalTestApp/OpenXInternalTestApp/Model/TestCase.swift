//
//  TestCase.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
import UIKit


//This enum is used to create labels for Test Cases and filter
enum TestCaseTag : String, Comparable {
    
    // MARK: - Tags
    
    //Connection
    case server = "📡"
    case mock = "🎭"
    
    //Appearance
    case banner = "Banner"
    case interstitial = "Interstitial"
    case video = "Video"
    case mraid = "MRAID"
    case native = "Native"
    
    
    //SDK (Integration)
    case apollo = "Apollo "
    case gam    = "GAM"
    case mopub  = "MoPub"
    
    // MARK: - Group
    static var connections: [TestCaseTag] {
        return [.mock, .server]
    }
    
    static var appearance: [TestCaseTag] {
        return [.banner, .interstitial, .video, .mraid, .native]
    }
    
    static var integrations: [TestCaseTag] {
        return [.apollo, .gam, .mopub]
    }
    
    // MARK: - Util methods
    
    // Returns only "appearance" tags that present in the input array
    static func extractAppearances(from tags: [TestCaseTag]) -> [TestCaseTag] {
        return collectTags(from: TestCaseTag.appearance, in: tags)
    }
    
    // Returns only "integrations" tags that present in the input array
    static func extractIntegrations(from tags: [TestCaseTag]) -> [TestCaseTag] {
        return collectTags(from: TestCaseTag.integrations, in: tags)
    }
    
    // Returns only "connections" tags that present in the input array
    static func extractConnections(from tags: [TestCaseTag]) -> [TestCaseTag] {
        return collectTags(from: TestCaseTag.connections, in: tags)
    }
    
    // Returns intersection of two arrays of tags
    // We need a sorted list to have consistent appearance in UI
    static func collectTags(from targetTags: [TestCaseTag], in tags: [TestCaseTag]) -> [TestCaseTag] {
        return tags
            .intersection(targetTags)
            .sorted(by: <=)
    }
    
    static func <(lhs: TestCaseTag, rhs: TestCaseTag) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
}

struct TestCase {
    let title: String
    let tags: [TestCaseTag]
    
    let exampleVCStoryboardID: String
    let configurationClosure: ((_ vc: UIViewController) -> Void)?
    
    func byAdding(tag: TestCaseTag) -> TestCase {
        return TestCase(title: title,
                        tags: tags + [tag],
                        exampleVCStoryboardID: exampleVCStoryboardID,
                        configurationClosure: configurationClosure)
    }
}

struct TestCaseForTableCell {
    let configurationClosureForTableCell: ((_ cell: inout UITableViewCell?) -> Void)?
}
