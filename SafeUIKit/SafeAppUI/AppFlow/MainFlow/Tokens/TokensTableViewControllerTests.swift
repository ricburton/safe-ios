//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport
import Common
import SafeUIKit

class TokensTableViewControllerTests: SafeTestCase {

    let controller = TokensTableViewController()

    override func setUp() {
        super.setUp()
        walletService.visibleTokensOutput = [TokenData.eth, TokenData.gno, TokenData.mgn]
    }

    func test_whenCreated_thenLoadsData() {
        createWindow(controller)
        controller.notify()
        delay()
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 2)
        let firstCell = cell(at: 0, 0)
        let secondCell = cell(at: 0, 1)
        let thirdCell = cell(at: 1, 1)
        XCTAssertEqual(firstCell.tokenCodeLabel.text, "Ether")
        XCTAssertEqual(firstCell.tokenBalanceCodeLabel.text, "ETH")
        XCTAssertEqual(firstCell.tokenBalanceLabel.text?.replacingOccurrences(of: ",", with: "."), "0.01")
        XCTAssertEqual(secondCell.tokenCodeLabel.text, "Gnosis")
        XCTAssertEqual(secondCell.tokenBalanceCodeLabel.text, "GNO")
        XCTAssertEqual(secondCell.tokenBalanceLabel.text?.replacingOccurrences(of: ",", with: "."), "1.00")
        XCTAssertEqual(thirdCell.tokenCodeLabel.text, "Magnolia")
        XCTAssertEqual(thirdCell.tokenBalanceLabel.text, "--")
    }

    func test_whenCreated_thenSyncs() {
        createWindow(controller)
        XCTAssertTrue(walletService.didSync)
    }

    func test_whenSelectingRow_thenDeselectsIt() {
        createWindow(controller)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func test_whenSelectingRow_thenCallsDelegate() {
        let delegate = MockMainViewControllerDelegate()
        controller.delegate = delegate
        createWindow(controller)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(delegate.didCallCreateNewTransaction)
    }

    func test_whenThereAreNoTokens_thenTokensFooterIsShown() {
        walletService.visibleTokensOutput = [TokenData.eth]
        createWindow(controller)
        controller.notify()
        let footer = controller.tableView(controller.tableView, viewForFooterInSection: 1)
        XCTAssertTrue(footer is AddTokenFooterView)
    }

    func test_whenCreatingHeader_thenDequeuesIt() {
        createWindow(controller)
        controller.notify()
        let footer = controller.tableView(controller.tableView, viewForHeaderInSection: 1)
        XCTAssertTrue(footer is TokensHeaderView)
    }

}

private extension TokensTableViewControllerTests {

    func cell(at row: Int, _ section: Int) -> TokenBalanceTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: section)) as! TokenBalanceTableViewCell
    }

}
