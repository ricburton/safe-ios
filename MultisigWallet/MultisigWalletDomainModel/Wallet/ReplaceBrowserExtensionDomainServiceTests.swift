//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport

class ReplaceBrowserExtensionDomainServiceTests: XCTestCase {

    let service = ReplaceBrowserExtensionDomainService()
    let walletRepo = InMemoryWalletRepository()
    let portfolioRepo = InMemorySinglePortfolioRepository()
    let transactionRepo = InMemoryTransactionRepository()

    let mockEncryptionService = MockEncryptionService()
    let accountRepo = InMemoryAccountRepository()
    let mockRelayService = MockTransactionRelayService(averageDelay: 0, maxDeviation: 0)
    let mockProxy = TestableOwnerProxy(Address.testAccount1)

    var ownersWithoutExtension = OwnerList([
        Owner(address: Address.testAccount1, role: .thisDevice),
        Owner(address: Address.testAccount3, role: .paperWallet),
        Owner(address: Address.testAccount4, role: .paperWalletDerived)])

    var ownersWithExtension = OwnerList([
        Owner(address: Address.testAccount1, role: .thisDevice),
        Owner(address: Address.testAccount2, role: .browserExtension),
        Owner(address: Address.testAccount3, role: .paperWallet),
        Owner(address: Address.testAccount4, role: .paperWalletDerived)])

    var noOwners = OwnerList()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: transactionRepo, for: TransactionRepository.self)
        DomainRegistry.put(service: mockEncryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: accountRepo, for: AccountRepository.self)
        DomainRegistry.put(service: mockRelayService, for: TransactionRelayDomainService.self)
        mockProxy.getOwners_result = ownersWithExtension.sortedOwners().map { $0.address }
        service.ownerContractProxy = mockProxy
    }

    func test_whenSafeExistsAndExtensionSetUp_thenAvailable() {
        setUpPortfolio(wallet: wallet(owners: ownersWithExtension))
        XCTAssertTrue(service.isAvailable)
    }

    func test_whenConditionsNotMet_thenNotAvailalbe() {
        XCTAssertFalse(service.isAvailable, "No portfolio, no wallet")
    }

    func test_whenPortfolioWihtoutWalelts_thenNotAvailable() {
        setUpPortfolio(wallet: nil)
        XCTAssertFalse(service.isAvailable, "Portfolio, no wallets")
    }

    func test_whenPortfolioWalletWithoutOwners_thenNotAvailable() {
        setUpPortfolio(wallet: wallet(owners: noOwners))
        XCTAssertFalse(service.isAvailable, "Portfolio, wallet, no owners")
    }

    func test_whenPortfolioWalletOwnersNoExtension_thenNotAvailable() {
        setUpPortfolio(wallet: wallet(owners: ownersWithoutExtension))
        XCTAssertFalse(service.isAvailable, "No extension")
    }

    func test_whenCreatingTransaction_thenHasBasicFieldsSet() {
        let wallet = setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        XCTAssertEqual(tx.sender, wallet.address)
        XCTAssertEqual(tx.accountID.tokenID, Token.Ether.id)
        XCTAssertEqual(tx.accountID.walletID, wallet.id)
        XCTAssertEqual(tx.walletID, wallet.id)
        XCTAssertEqual(tx.amount, TokenAmount.ether(0))
        XCTAssertEqual(tx.type, .replaceBrowserExtension)
    }

    func test_whenDeletingTransaction_thenRemovedFromRepository() {
        setUpWallet()
        let txID = service.createTransaction()
        service.deleteTransaction(id: txID)
        XCTAssertNil(transaction(from: txID))
    }

    func test_whenAddingDummyData_thenCreatesDummyTransactionFields() {
        let wallet = setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        let tx = transaction(from: txID)!
        XCTAssertEqual(tx.operation, .call)
        XCTAssertEqual(tx.data, service.dummySwapData())
        XCTAssertEqual(tx.recipient, wallet.address!)
    }

    func test_whenRemovesDummyData_thenRemovesFields() {
        setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        service.removeDummyData(from: txID)
        let tx = transaction(from: txID)!
        XCTAssertNil(tx.operation)
        XCTAssertNil(tx.data)
        XCTAssertNil(tx.recipient)
    }

    func test_whenEstimatingNetworkFees_thenDoesSo() {
        let expectedFee = TokenAmount.ether(30)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        setUpWallet()
        let txID = service.createTransaction()
        service.addDummyData(to: txID)
        let actualFee = try! service.estimateNetworkFee(for: txID)
        XCTAssertEqual(actualFee, expectedFee)
    }

    func test_whenAccountBalanceQueried_thenReturnsIt() {
        setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        let expectedBalance: TokenInt = 123
        setUpAccount(transaction: tx, balance: expectedBalance)
        XCTAssertEqual(service.accountBalance(for: tx.id), TokenAmount.ether(expectedBalance))
    }

    func test_whenResultingBalanceCalculated_thenSummedWithChangedAmount() {
        setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        setUpAccount(transaction: tx, balance: 0)
        XCTAssertEqual(service.resultingBalance(for: tx.id, change: TokenAmount.ether(-1)), TokenAmount.ether(-1))
    }

    func test_whenValidatingTransaction_thenThrowsOnBalanceError() {
        setUpWallet()
        let tx = transaction(from: service.createTransaction())!
        setUpAccount(transaction: tx, balance: 0)
        service.addDummyData(to: tx.id)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        _ = try! service.estimateNetworkFee(for: tx.id)
        XCTAssertThrowsError(try service.validate(transactionID: tx.id))
    }

    func test_whenValidating_thenThrowsOnInexistingExtension() {
        setUpPortfolio(wallet: wallet(owners: ownersWithoutExtension))
        let tx = transaction(from: service.createTransaction())!
        setUpAccount(transaction: tx, balance: 100)
        service.addDummyData(to: tx.id)
        setNetworkFee(safeGas: 1, dataGas: 1, operationGas: 1, gasPrice: 10)
        _ = try! service.estimateNetworkFee(for: tx.id)
        XCTAssertThrowsError(try service.validate(transactionID: tx.id))
    }

}

class TestableOwnerProxy: SafeOwnerManagerContractProxy {

    var getOwners_result = [Address]()

    override func getOwners() throws -> [Address] {
        return getOwners_result
    }
}

extension ReplaceBrowserExtensionDomainServiceTests {

    func setNetworkFee(safeGas: Int, dataGas: Int, operationGas: Int, gasPrice: Int) {
        mockRelayService.estimateTransaction_output = .init(safeTxGas: safeGas,
                                                            dataGas: dataGas,
                                                            operationalGas: operationGas,
                                                            gasPrice: gasPrice,
                                                            lastUsedNonce: nil,
                                                            gasToken: Token.Ether.address.value)
    }

    func setUpAccount(transaction tx: Transaction, balance: TokenInt) {
        let account = Account(tokenID: tx.accountID.tokenID, walletID: tx.accountID.walletID, balance: balance)
        accountRepo.save(account)
    }

    @discardableResult
    func setUpWallet() -> Wallet {
        let result = wallet(owners: ownersWithExtension)
        setUpPortfolio(wallet: result)
        return result
    }

    func transaction(from id: TransactionID) -> Transaction? {
        return transactionRepo.findByID(id)
    }

    func wallet(owners: OwnerList) -> Wallet {
        let walletID = walletRepo.nextID()
        let walletAddress = Address.safeAddress
        let wallet = Wallet(id: walletID,
                            state: .readyToUse,
                            owners: owners,
                            address: walletAddress,
                            minimumDeploymentTransactionAmount: nil,
                            creationTransactionHash: nil)
        walletRepo.save(wallet)
        return wallet
    }

    func setUpPortfolio(wallet: Wallet?) {
        let portfolio = Portfolio(id: portfolioRepo.nextID(),
                                  wallets: wallet == nil ? WalletIDList() : WalletIDList([wallet!.id]),
                                  selectedWallet: wallet?.id)
        portfolioRepo.save(portfolio)
    }

}
