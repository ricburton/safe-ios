//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class ImMemoryTokenListItemRepositoryTests: XCTestCase {

    let repository = InMemoryTokenListItemRepository()

    func test_Find_Remove_All_Save() {
        let eth = Token.Ether
        let item = TokenListItem(token: eth, status: .whitelisted)
        repository.save(item)
        XCTAssertEqual(repository.find(id: eth.id), item)
        XCTAssertEqual(repository.all().count, 1)
        let item2 = TokenListItem(token: Token.gno, status: .regular)
        repository.save(item2)
        let all = repository.all()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all[0].token, eth)
        XCTAssertEqual(all[0].status, .whitelisted)
        XCTAssertEqual(all[1].token, Token.gno)
        XCTAssertEqual(all[1].status, .regular)
        repository.remove(item)
        XCTAssertNil(repository.find(id: eth.id))
        XCTAssertEqual(repository.all().count, 1)
    }

    func test_whenSavingWhitelistedItem_thenAssignsProperSortingOrder() {
        let gno = TokenListItem(token: Token.gno, status: .whitelisted)
        let rdn = TokenListItem(token: Token.rdn, status: .regular)
        let mgn = TokenListItem(token: Token.mgn, status: .whitelisted)
        repository.save(gno)
        repository.save(rdn)
        repository.save(mgn)

        // Correct assignment of new sorting ids for new whitelisted tokens
        let savedGNO = repository.find(id: Token.gno.id)!
        XCTAssertEqual(savedGNO.sortingId, 0)
        let savedRDN = repository.find(id: Token.rdn.id)!
        XCTAssertEqual(savedRDN.sortingId, nil)
        let savedMGN = repository.find(id: Token.mgn.id)!
        XCTAssertEqual(savedMGN.sortingId, 1)

        // Updating whitelisted token should not influence its sorting id
        repository.save(savedGNO)
        let savedGNO_1 = repository.find(id: Token.gno.id)!
        XCTAssertEqual(savedGNO_1.sortingId, 0)

        // Updating status of whitelisted token should remove its sorting id
        let blacklistedGNO = TokenListItem(token: Token.gno, status: .blacklisted)
        repository.save(blacklistedGNO)
        let savedGNO_2 = repository.find(id: Token.gno.id)!
        XCTAssertEqual(savedGNO_2.sortingId, nil)

        // New whitelisted token takes next available sorting id
        let whitelistedRDN = TokenListItem(token: Token.rdn, status: .whitelisted)
        repository.save(whitelistedRDN)
        let savedRDN_2 = repository.find(id: Token.rdn.id)!
        XCTAssertEqual(savedRDN_2.sortingId, 2)
    }

}
