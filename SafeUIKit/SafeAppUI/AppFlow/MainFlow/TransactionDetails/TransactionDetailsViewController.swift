//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import DateTools
import MultisigWalletApplication
import SafeUIKit

public protocol TransactionDetailsViewControllerDelegate: class {
    func showTransactionInExternalApp(from controller: TransactionDetailsViewController)
}

internal class ClockService {
    var currentTime: Date {
        return Date()
    }
}

public class TransactionDetailsViewController: UIViewController {

    struct Strings {
        static let type = LocalizedString("transaction.details.type", comment: "'Type' parameter name")
        static let submitted = LocalizedString("transaction.details.submitted",
                                               comment: "'Submitted' parameter name")
        static let status = LocalizedString("transaction.details.status", comment: "'Status' parameter name")
        static let fee = LocalizedString("transaction.details.fee", comment: "'Fee' parameter name")
        static let externalApp = LocalizedString("transaction.details.externalViewer",
                                                 comment: "'View on Etherscan' button name")
        static let outgoing = LocalizedString("transaction.details.type.outgoing",
                                              comment: "'Outgoing' transaction type")
        static let incoming = LocalizedString("transaction.details.type.incoming",
                                              comment: "'Incoming' transaction type")
        static let title = LocalizedString("transaction.details.title",
                                           comment: "Title for the transaction details screen")
    }

    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var transferView: TransferView!
    @IBOutlet weak var transactionTypeView: TransactionParameterView!
    @IBOutlet weak var submittedParameterView: TransactionParameterView!
    @IBOutlet weak var transactionStatusView: StatusTransactionParameterView!
    @IBOutlet weak var transactionFeeView: TokenAmountTransactionParameterView!
    @IBOutlet weak var viewInExternalAppButton: UIButton!
    @IBOutlet weak var wrapperView: ShadowWrapperView!
    public weak var delegate: TransactionDetailsViewControllerDelegate?
    public private(set) var transactionID: String!
    private var transaction: TransactionData!
    internal var clock = ClockService()

    private let dateFormatter = DateFormatter()

    public static func create(transactionID: String) -> TransactionDetailsViewController {
        let controller = StoryboardScene.Main.transactionDetailsViewController.instantiate()
        controller.transactionID = transactionID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        ApplicationServiceRegistry.walletService.subscribeForTransactionUpdates(subscriber: self)
        backgroundImageView.isDimmed = true
        wrapperView.backgroundColor = ColorName.paleGreyThree.color
        reloadData()
    }

    private func reloadData() {
        transaction = ApplicationServiceRegistry.walletService.transactionData(transactionID)
        configureTransferDetails()
        configureType()
        configureSubmitted()
        configureStatus()
        configureFee()
        configureViewInOtherApp()
    }

    private func configureTransferDetails() {
        transferView.fromAddress = transaction.sender
        transferView.toAddress = transaction.recipient
        transferView.tokenData = transaction.amountTokenData
    }

    private func configureType() {
        transactionTypeView.name = Strings.type
        switch transaction.type {
        case .outgoing: transactionTypeView.value = Strings.outgoing
        case .incoming: transactionTypeView.value = Strings.incoming
        }
    }

    private func configureSubmitted() {
        submittedParameterView.name = Strings.submitted
        submittedParameterView.value = transaction.submitted == nil ? "--" : string(from: transaction.submitted!)
    }

    private func configureStatus() {
        transactionStatusView.name = Strings.status
        transactionStatusView.status = statusViewStatus(from: transaction.status)
        transactionStatusView.value = string(from: transaction.displayDate!)
    }

    func statusViewStatus(from status: TransactionData.Status) -> TransactionStatusParameter {
        switch status {
        case .rejected: return .rejected
        case .failed: return .failed
        case .success: return .success
        default: return .pending
        }
    }

    private func configureFee() {
        transactionFeeView.name = Strings.fee
        transactionFeeView.amountLabel.formatter.displayedDecimals = nil
        transactionFeeView.amount = transaction.feeTokenData.withBalance(-(transaction.feeTokenData.balance ?? 0))
    }

    private func configureViewInOtherApp() {
        viewInExternalAppButton.setTitle(Strings.externalApp, for: .normal)
        viewInExternalAppButton.removeTarget(self, action: nil, for: .touchUpInside)
        viewInExternalAppButton.addTarget(self, action: #selector(viewInExternalApp), for: .touchUpInside)
    }

    @objc private func viewInExternalApp() {
        delegate?.showTransactionInExternalApp(from: self)
    }

    func string(from date: Date) -> String {
        return "\(dateFormatter.string(from: date)) (\(date.timeAgo(since: clock.currentTime)))"
    }

}

extension TransactionDetailsViewController: EventSubscriber {

    public func notify() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

}
