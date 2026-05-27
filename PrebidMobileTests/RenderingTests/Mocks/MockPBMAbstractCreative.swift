//
//  MockPBMAbstractCreative.swift
//  PrebidMobileTests
//
//  Created by Olena Stepaniuk on 06.03.2023.
//  Copyright © 2023 AppNexus. All rights reserved.
//

import Foundation
@_spi(PBMInternal) @testable import PrebidMobile

class MockPBMAbstractCreative: PBMAbstractCreative_Objc {
 
    var modalManagerDidFinishPopCallback: VoidBlock?
    var modalManagerDidLeaveAppCallback: VoidBlock?
    
    override func modalManagerDidFinishPop(_ state: ModalState) {
        modalManagerDidFinishPopCallback?()
    }
    
    override func modalManagerDidLeaveApp(_ state: ModalState) {
        modalManagerDidLeaveAppCallback?()
    }
}
