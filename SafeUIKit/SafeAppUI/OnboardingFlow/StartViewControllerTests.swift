//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class StartViewControllerTests: XCTestCase {

    // swiftlint:disable:next weak_delegate
    let delegate = MockStartViewControllerDelegate()
    var vc: StartViewController!

    override func setUp() {
        super.setUp()
        delegate.wasCalled = false
        vc = StartViewController.create(delegate: delegate)
        vc.loadViewIfNeeded()
    }

    func test_canCreate() {
        XCTAssertNotNil(vc.descriptionLabel)
    }

    func test_whenSetupPasswordActionSent_thenDelegateCalled() {
        vc.setupPassword(self)
        XCTAssertTrue(delegate.wasCalled)
    }

}

class MockStartViewControllerDelegate: StartViewControllerDelegate {

    var wasCalled = false

    func didStart() {
        wasCalled = true
    }

}
